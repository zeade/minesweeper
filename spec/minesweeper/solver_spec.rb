require 'spec_helper'

module Minesweeper
  RSpec.describe Solver do
    let(:solver) { Solver.new }

    describe '.run' do
      let(:tries) { 5 }
      let(:debug) { true }
      subject { Solver.run(tries: tries, debug: debug) }
      it 'is a class wrapper for #solve' do
        expect_any_instance_of(Solver).to receive(:solve).with(tries: tries)
        subject
      end
    end

    describe '#solve' do
      let(:tries) { 10 }
      subject { solver.solve(tries: tries) }
      it 'will call #solve_one as many times as specified' do
        expect(solver).to receive(:solve_one).exactly(10).times.and_return(0, 1)  # return 1 loss and the rest (9) wins
        subject
        expect(solver.wins).to eq(9)
        expect(solver.losses).to eq(1)
      end
    end
  end
end
