require 'readline'

module Minesweeper
  class Game
    attr_accessor :board

    KABOOM =<<-'EOS'
       _         _                           _
      | | ____ _| |__   ___   ___  _ __ ___ | |
      | |/ / _` | '_ \ / _ \ / _ \| '_ ` _ \| |
      |   < (_| | |_) | (_) | (_) | | | | | |_|
      |_|\_\__,_|_.__/ \___/ \___/|_| |_| |_(_)

      ...game over ...type 'new' to play again
    EOS

    WINNER =<<-'EOS'
                                    _       _
       _   _  ___  _   _  __      _(_)_ __ | |
      | | | |/ _ \| | | | \ \ /\ / / | '_ \| |
      | |_| | (_) | |_| |  \ V  V /| | | | |_|
       \__, |\___/ \__,_|   \_/\_/ |_|_| |_(_)
       |___/

      ...type 'new' to play again
    EOS

    # Run from class wrapper
    def self.run
      game = self.new
      game.run
    end

    def initialize(rows_count: 20, columns_count: rows_count, mines_count: (rows_count * columns_count / 8))
      @rows_count = rows_count
      @columns_count = columns_count
      @mines_count = mines_count
      new_board
    end

    def run
      print board.text_display
      while (user_input = Readline.readline(prompt, true)) do
        cmd, *args = user_input.chomp.split /[,\s]+/

        case cmd
        when /\An(ew)?\z/i
          @rows_count    = args[0].to_i if args[0]
          @columns_count = args[1] ? args[1].to_i : @rows_count
          @mines_count   = args[2] ? args[2].to_i : @rows_count * @columns_count / 8
          new_board
          print board.text_display
        when /\A(u(ncover)?|c(lick|heck)?|p(ick)?)\z/i
          modify_tile(cmd, args) do |row, col|
            if board.tile(row, col).covered?
              if @first_pick
                board.uncover_first(row, col)
                @first_pick = false
              else
                board.uncover(row, col)
              end
            else
              board.uncover_adjacent(row, col)
            end
            if board.lost?
              # KABOOM!
              print board.text_display(game_over: true)
              print KABOOM
            else
              print board.text_display
              print WINNER if board.won?
            end
          end
        when /\Af(lag)?\z/i
          modify_tile(cmd, args) do |row, col|
            if board.flag(row, col) != nil
              print board.text_display
            end
          end
        when /\Apr(int)?\z/i
          print board.text_display
        when /\Axray\z/i
          print board.text_display(game_over: true)
        when /\Ah(elp)?\z/i
          print help
        else
          puts "Sorry, I don't understand, try typing: help"
        end
      end
    end

    def new_board
      @board = Minesweeper::Board.new(rows_count: @rows_count, columns_count: @columns_count, mines_count: @mines_count)
      @turns = 0
      @first_pick = true
    end

    def help
      <<~"EOS"
        Commands:
          new [rows] [columns] [bombs]
            starts new game

          uncover <row> <col>
            uncovers tile (aliases: check, click, pick)

          flag <row> <col>
            flags tile as a bomb

          print
            displays board again

        Current board: #{@rows_count} rows, #{@columns_count} columns, #{@mines_count} mines
      EOS
    end

    private

    def prompt
      "[#{@turns}]>> "
    end

    def modify_tile(command, args)
      if args.length != 2 || args[0] !~ /\A\d+\z/ || args[1] !~ /\A\d+\z/
        puts "Usage: #{command} <row> <col>\n  row must be between 0 and #{@rows_count - 1}, column must be between 0 and #{@columns_count - 1}"
      else
        @turns += 1
        # Force int values
        yield(args.map { |arg| arg.to_i })
      end
    end

  end
end
