module Minesweeper
  class Board
    attr_accessor :columns_count, :rows_count, :mines_count

    # Directional offsets on a 2d row and column grid
    # NW N NE
    # W  +  E
    # SW S SE
    DIRECTIONS = {
      northwest: [-1, -1],
      north: [-1, 0],
      northeast: [-1, 1],
      west: [0, -1],
      east: [0, 1],
      southwest: [1, -1],
      south: [1, 0],
      southeast: [1, 1]
    }
    # For display
    COLUMN_WIDTH = 3

    def initialize(rows_count: 20, columns_count: rows_count, mines_count: (rows_count * columns_count / 8))
      @rows_count = rows_count
      @columns_count = columns_count
      @mines_count = mines_count

      # Create an array of tiles with number of mines set, shuffle and store as 2d array (aka "unflattening" the array).
      @tiles = []
      (@columns_count * @rows_count).times do |i|
        @tiles << Minesweeper::Tile.new(mine: i < @mines_count)
      end
      @tiles = @tiles.shuffle.each_slice(columns_count).to_a

      # Populate tile grid positions and adjacency. Not space efficient, but makes some other things easier. Blows up
      # using when irb (inspect overriden, see below). To allow similar ease but not pre-calculate could pass board to
      # tile to determine as needed.
      all_tiles do |t, row, col|
        t.row = row
        t.column = col
        adjacent_positions(row, col) do |*pos|
          t.adjacent << tile(*pos)
        end
      end
    end

    # Create a set of helper methods, 'northwest', 'north', etc to return valid positions on the grid given a
    # starting point
    DIRECTIONS.each do |direction, offsets|
      # Takes argument list or array blindly, i.e. both north(1, 1) and north([1,1]) return [0,1]
      define_method direction do |*args|
        row, col = *args.flatten
        row += offsets[0]
        col += offsets[1]
        [row, col] if in_bounds?(row, col)
      end
    end

    # Returns a set of valid positions on grid that are neighbors of the given position. Will call block per neighbor
    # position if block is passed.
    def adjacent_positions(row, col)
      positions = []
      %i( northwest north northeast west east southwest south southeast ).each do |direction|
        pos = send direction, row, col
        next unless pos
        if block_given?
          yield *pos
        else
          positions << pos
        end
      end
      positions
    end
    
    # Strip out @tiles spam
    def inspect
      ivars = self.instance_variables.map do |ivar|
        if ivar == :@tiles
          "#{ivar}=[#{@tiles.count}][#{@tiles.last.count}]"
        else
          "#{ivar}=#{instance_variable_get(ivar).inspect}"
        end
      end
      "<#{self.class}: #{ivars.join(", ")}>"
    end

    def tile(row, col)
      @tiles[row][col] if in_bounds?(row, col)
    end

    # All tiles, either as flattened array or yielding to block with row and column also passed (like 2d Array#each_with_index)
    def all_tiles
      if block_given?
        @tiles.each_with_index do |tile_row, row|
          tile_row.each_with_index do |t, col|
            yield t, row, col
          end
        end
      else
        @tiles.flatten
      end
    end

    # Reset board to untouched state (covered and no flags)
    def reset
      all_tiles.each { |t| t.reset }
    end

    # Text formatted for vt100 terminal display
    def text_display(game_over: false)
      # Top
      grid = display_column_indexes
      # Tiles
      rows_count = 0
      @tiles.each do |tile_row|
        grid << sprintf("%#{COLUMN_WIDTH}d", rows_count)
        tile_row.each do |t|
          grid << (game_over || lost? ? t.text_display_game_over : t.text_display)
        end
        grid << sprintf("%#{COLUMN_WIDTH}d", rows_count)
        grid << "\n"
        rows_count += 1
      end
      # Bottom
      grid << display_column_indexes
      grid
    end

    # Uncover selected tile (L click), clear tiles around it if not surrounded by mines (and so on)
    def uncover(row, col)
      # Noop if tile is flagged or already uncovered
      return if !(t = tile(row, col)) || t.uncovered? || t.flagged?
      t.uncover!
      # Uncover adjacent if surrounded count is 0
      if t.adjacent_mines_count == 0
        t.adjacent.each do |a|
          uncover(a.row, a.column)
        end
      end
      # Return true if not a mine
      ! t.mine?
    end

    # Allow first picked tile to always be empty, even if not originally
    def uncover_first(row, col)
      return unless (orig = tile(row, col)) || orig.uncovered? || orig.flagged?
      if orig.mine?
        empty = all_tiles.find { |t| !t.mine? }
        return unless empty # FIXME?: we have a board full o' mines...
        empty.mine = true
        orig.mine = false
      end
      uncover(row, col)
    end

    # Uncover tiles around selected and uncovered tile (L+R click), possibly blows up unflagged mines
    def uncover_adjacent(row, col)
      return if !(t = tile(row, col)) || t.covered? || t.adjacent_mines_count == 0
      t.adjacent.each do |a|
        uncover(a.row, a.column)
      end
    end

    # Flag a tile as a mine (R click)
    def flag(row, col)
      # Noop if tile is uncovered
      return if !(t = tile(row, col)) || t.uncovered?
      t.flag!
    end

    def won?
      all_tiles.count { |t| t.uncovered? } == rows_count * columns_count - mines_count && ! lost?
    end

    def lost?
      all_tiles.find { |t| t.mine? && t.uncovered? } != nil
    end

    def in_bounds?(row, col)
      row > -1 && row < rows_count && col > -1 && col < columns_count
    end

    def edge_or_uncovered?(row, col)
      !(t = tile(row, col)) || t.uncovered?
    end

    private

    def display_column_indexes
      header = ' ' * COLUMN_WIDTH
      columns_count.times do |i|
        header << sprintf("%#{COLUMN_WIDTH}d", i)
      end
      header << "\n"
      header
    end

  end
end
