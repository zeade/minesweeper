require 'spec_helper'

module Minesweeper
  RSpec.describe Board do
    let(:board) { Board.new(rows_count: 10, columns_count: 10, mines_count: 10) }

    describe 'directional helper methods' do
      it 'nil if out of bounds' do
        expect(board.north(100, 100)).to be nil
      end
      it 'can take either list or array arguments' do
        expect(board.east(0, 0)).to eq([0, 1])
        expect(board.east([0, 0])).to eq([0, 1])
      end
      it '#northwest' do
        expect(board.northwest(2, 2)).to eq([1, 1])
      end
      it '#north' do
        expect(board.north(2, 2)).to eq([1, 2])
      end
      it '#northeast' do
        expect(board.northeast(2, 2)).to eq([1, 3])
      end
      it '#west' do
        expect(board.west(2, 2)).to eq([2, 1])
      end
      it '#east' do
        expect(board.east(2, 2)).to eq([2, 3])
      end
      it '#southwest' do
        expect(board.southwest(2, 2)).to eq([3, 1])
      end
      it '#south' do
        expect(board.south(2, 2)).to eq([3, 2])
      end
      it '#southeast' do
        expect(board.southeast(2, 2)).to eq([3, 3])
      end
    end

    describe '#in_bounds?' do
      let(:row) { 1 }
      let(:column) { 1 }
      subject { board.in_bounds?(row, column) }
      it 'returns true if row and column are on the grid' do
        expect(subject).to be true
      end
      context 'when out of bounds' do
        let(:column) { -1 }
        it('is false') { expect(subject).to be false }
      end
    end

    describe '#tile' do
      let(:row) { 5 }
      let(:column) { 5 }
      subject { board.tile(row, column) }
      it 'returns the tile at the row and column' do
        expect(subject).to_not be_nil
        expect(subject.row).to eq(5)
        expect(subject.column).to eq(5)
      end
      context 'when out of bounds' do
        let(:row) { 11 }
        it('is nil') { expect(subject).to be nil }
      end
    end
  end

  describe '#adjacent_positions' do
    subject { board.adjacent_positions(1,1) }
    it 'returns an array of row and column pairs of adjacent positions on a grid' do
      expect(subject).to include([0, 1], [2, 2])
      expect(subject.count).to eq(8)
    end
  end

end
