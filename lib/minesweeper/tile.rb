module Minesweeper
  class Tile

    class AlreadyUncoveredError < StandardError; end

    attr_accessor :mine, :flagged, :covered, :row, :column, :adjacent

    alias_method :mine?, :mine
    alias_method :flagged?, :flagged
    alias_method :covered?, :covered

    # Display states, using Unicode and ANSI escapes (blink, color)
    MINE    = "  \u{1F4A3}"
    # FLAG    = "  \u{1F3F3}"
    # FLAG    = "  \u{2691}"
    MONKEYS = [
      "  \u{1F648}",
      "  \u{1F649}",
      "  \u{1F64A}"
    ]
    FLAGS = MONKEYS
    # COVERED = "  \u{25FD}"
    COVERED = "  \u{2593}"
    EMPTY   = "  ."
    KABOOM  = " \x1b[5;41m\u{1F4A5} \x1b[0m"
    ADJACENT_MINES = [
      "  \u{2460}",  # 1 in a circle
      "  \u{2461}",  # 2
      "  \u{2462}",
      "  \u{2463}",
      "  \u{2464}",
      "  \u{2465}",
      "  \u{2466}",
      "  \u{2467}"   # 8
    ]
    FLAGGED_EMPTY = "  \u{2049}"

    def initialize(mine: false, covered: true, flagged: false)
      @mine = mine
      @covered = covered
      @flagged = flagged
      @row = 0
      @column = 0
      @adjacent = []
    end

    def reset
      @covered = true
      @flagged = false
    end

    def inspect
      ivars = self.instance_variables.map do |ivar|
        if ivar == :@adjacent
          "#{ivar}=[#{@adjacent.count}]"
        else
          "#{ivar}=#{instance_variable_get(ivar).inspect}"
        end
      end
      "<#{self.class}: #{ivars.join(", ")}>"
    end

    def text_display
      if flagged?
        MONKEYS[rand(MONKEYS.length)]
      elsif covered?
        COVERED
      elsif mine?
        KABOOM
      elsif adjacent_mines_count > 0
        ADJACENT_MINES[adjacent_mines_count - 1]
      else
        EMPTY
      end
    end

    def text_display_game_over
      if flagged? && mine?
        MONKEYS[rand(MONKEYS.length)]
      elsif flagged?
        FLAGGED_EMPTY
      elsif mine? && covered?
        MINE
      elsif mine?
        KABOOM
      elsif adjacent_mines_count > 0
        ADJACENT_MINES[adjacent_mines_count - 1]
      else
        EMPTY
      end
    end

    def flag!
      raise AlreadyUncoveredError.new if uncovered?
      @flagged = ! flagged?
    end

    def uncover!
      raise AlreadyUncoveredError.new if uncovered?
      @covered = false
    end

    def uncovered?
      ! covered?
    end

    def unflagged?
      ! flagged?
    end

    def untouched?
      covered? && unflagged?
    end

    def adjacent_flagged_count
      adjacent.count { |t| t.flagged? }
    end

    def adjacent_mines_count
      adjacent.count { |t| t.mine? }
    end

    def adjacent_covered_count
      adjacent.count { |t| t.covered? }
    end

    def adjacent_untouched_count
      adjacent.count { |t| t.untouched? }
    end

  end
end
