require 'spec_helper'

module Minesweeper
  RSpec.describe Tile do
    let(:tile) { Tile.new }

    describe '#flag!' do
      subject { tile.flag! }
      it 'toggles flag' do
        expect { subject }.to change { tile.flagged? }
      end
      it 'raises error if already uncovered' do
        tile.uncover!
        expect { subject }.to raise_error(Tile::AlreadyUncoveredError)
      end
    end

    describe '#uncover!' do
      subject { tile.uncover! }
      it 'toggles cover state' do
        expect { subject }.to change { tile.uncovered? }
      end
      it 'raises error if already uncovered' do
        tile.uncover!
        expect { subject }.to raise_error(Tile::AlreadyUncoveredError)
      end
    end

    describe '#text_display' do
      subject { tile.text_display }
      it 'displays covered if untouched' do
        expect(subject).to match("\u{2593}") # DARK SHADE
      end
      context 'when flagged' do
        before { tile.flag! }
        it 'displays a monkey' do
          expect(subject).to satisfy { |v| Tile::MONKEYS.include? v }
        end
      end
      context 'when uncovered' do
        before { tile.uncover! }
        it 'displays kaboom if a mine' do
          tile.mine = true
          expect(subject).to match("\u{1F4A5}") # COLLISION SYMBOL
        end
        it 'displays number of adjacent mines if there are any' do
          allow(tile).to receive(:adjacent_mines_count).and_return(3)
          expect(subject).to match("\u{2462}") # CIRCLED DIGIT THREE
        end
        it 'displays empty if no mine' do
          expect(subject).to match(".")
        end
      end
    end
  end
end
