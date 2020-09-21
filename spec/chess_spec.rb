require 'rspec'
require 'pry'
require './lib/chess.rb'

describe Rook do
  describe "#get_legal_moves" do
    xit "returns legal rook moves starting at space [1,1]" do
      rook = Rook.new([1,1], "black")
      expect(rook.get_legal_moves(rook.single_moves)).to eql([
        [[1,2],[1,3],[1,4],[1,5],[1,6],[1,7],[1,8]],
        [[2,1],[3,1],[4,1],[5,1],[6,1],[7,1],[8,1]]
      ])
    end

    xit "returns legal rook moves starting at space [2,2]" do
      rook = Rook.new([2,2], "black")
      expect(rook.get_legal_moves(rook.single_moves)).to eql([
        [[2,3],[2,4],[2,5],[2,6],[2,7],[2,8]],
        [[3,2],[4,2],[5,2],[6,2],[7,2],[8,2]],
        [[1,2]],
        [[2,1]]
      ])
    end
  end

  describe "#get_possible_moves" do
    xit "returns limited legal moves when another piece is in the way of a particular direction" do
      chess = Chess.new
      space = chess.board.detect { |space| space.coordinate == [1,3] }
      rook = Rook.new([1,3], "black")
      space.chess_piece = rook
      legal_moves = rook.get_legal_moves(rook.single_moves)
      expect(rook.get_possible_moves(legal_moves, chess.board)).to eql([
        [[1,4],[1,5],[1,6]],
        [[2,3],[3,3],[4,3],[5,3],[6,3],[7,3],[8,3]],
        []
      ])
    end
  end
end

describe Chess do
  describe "#select_piece" do
    it "returns the space of the valid piece the player selects" do
      chess = Chess.new
      player = Player.new('name', 'black')
      space = chess.board.detect { |space| space.coordinate == [1,1] }
      expect(chess.select_piece(player)).to eql(space)
    end
  end
end