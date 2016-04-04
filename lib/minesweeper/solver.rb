require 'benchmark'

module Minesweeper
  class Solver
    attr_accessor :board, :wins, :losses, :solve_time

    # Run from class wrapper
    def self.run(tries: 100_000, debug: false)
      solver = self.new(debug: debug)
      solver.solve(tries: tries)
    end

    def initialize(size: 10, mines: 10, debug: false)
      @wins = 0
      @losses = 0
      @solve_time = 0
      @size = size
      @mines = mines
      @debug = debug
    end

    def solve(tries: 100_000)
      @wins = 0
      @losses = 0
      @solve_time = Benchmark.realtime do
        tries.times do
          if solve_one == 1
            @wins += 1
          else
            @losses += 1
          end
        end
      end
      puts "wins: #{wins}, losses: #{losses}, took: #{solve_time.round(4)} sec"
    end

    def solve_one
      @board = Minesweeper::Board.new(rows_count: @size, mines_count: @mines)
      board.uncover_first 0, 0

      loop do
        display_board
        # stop
        return 0 if board.lost?
        return 1 if board.won?
        # Walk board till there are no single position logical are cleared or flagged
        loop do
          if simple_clear_and_flag == 0
            break
          else
            display_board
          end
        end
        # Clear any remaining tiles if we have put down as many flags as there are mines
        if board.all_tiles.count { |t| t.flagged? } == board.mines_count
          board.all_tiles.select { |t| t.untouched? }.each do |t|
            board.uncover t.row, t.column
          end
        # Pick (guess) a new tile to uncover
        elsif board.all_tiles.find { |t| t.untouched? }
          # Attempt to locate worst forced choice first to exit game early
          pick_fifty_fifty || pick_best_random
        end
      end
    end

    def stop
      print board.text_display
      gets
    end

    def display_board
      print board.text_display if @debug
    end

    def display_msg(msg)
      puts msg if @debug
    end

    def simple_clear_and_flag
      flags_set, tiles_cleared = 0, 0
      board.all_tiles do |t|
        # Untouched or already looked at, move on
        next if t.untouched? || t.flagged?

        mines = t.adjacent_mines_count

        # Not surrounded by mines, move on
        next if mines == 0

        flagged = t.adjacent_flagged_count
        untouched = t.adjacent_untouched_count

        # Nothing to do, move on
        next if untouched == 0

        # Clear any tiles that are not flagged if we have as many flags as untouched tiles
        if flagged == mines && untouched > 0
          t.adjacent.each do |a|
            next unless a.untouched?
            board.uncover a.row, a.column
            # Fail out if we somehow uncovered a mine
            fail if a.mine?
            tiles_cleared += 1
          end
        # Flag any untouched tiles that add up to total of remaining mines
        elsif flagged < mines && untouched == mines - flagged
          t.adjacent.each do |a|
            next unless a.untouched?
            a.flag!
            # Fail out if we somehow flagged an empty tile
            fail unless a.mine?
            flags_set += 1
          end
        end
      end
      flags_set + tiles_cleared
    end

    # Return any isolated pairs that can only be guessed at
    def pick_fifty_fifty
      pick = nil
      board.all_tiles.select { |t| t.adjacent_untouched_count == 1 }.each do |t|
        a = t.adjacent.find { |a| a.untouched? }
        if a.adjacent_untouched_count == 1
          pick = a
          break
        end
      end
      if pick
        display_msg "picking 50-50: (#{pick.row}, #{pick.column})"
        board.uncover pick.row, pick.column
      end
      pick
    end

    def pick_best_random
      best_ratio = 8  # (impossibly) best = 0.125
      best_tile = nil
      # Look at all uncovered tiles that have: surrounding mines count, untouched tiles
      board.all_tiles.select { |t| t.uncovered? && t.adjacent_mines_count > 0 && t.adjacent_untouched_count > 0 }.each do |t|
        r = t.adjacent_mines_count / t.adjacent_untouched_count.to_f
        if r < best_ratio
          best_ratio = r
          best_tile = t
        end
      end
      # We may not have a best selection
      pick = if best_tile
               pick = best_tile.adjacent.select { |t| t.untouched? }.sample
               display_msg "picking: (#{pick.row}, #{pick.column}), based on (#{best_tile.row}, #{best_tile.column}) (ratio=#{best_ratio.round(3)})"
               pick
             else
               pick = board.all_tiles.select { |t| t.untouched? }.sample
               display_msg "picking randomly: (#{pick.row}, #{pick.column})"
               pick
             end
      board.uncover pick.row, pick.column
    end
  end
end
