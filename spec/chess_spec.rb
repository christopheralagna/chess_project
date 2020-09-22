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
    it "returns limited legal moves when another piece is in the way of a particular direction, AND includes moves where opponent pieces reside" do
      chess = Chess.new
      player = Player.new('name', 'black')
      space = chess.board.detect { |space| space.coordinate == [1,3] }
      rook = Rook.new([1,3], "black")
      space.chess_piece = rook
      legal_moves = rook.get_legal_moves(rook.single_moves)
      expect(rook.get_possible_moves(legal_moves, chess.board, player)).to eql([
        [1,4],[1,5],[1,6],[1,7],
        [2,3],[3,3],[4,3],[5,3],[6,3],[7,3],[8,3]
      ])
    end
  end
end

describe Chess do
  describe "#select_piece" do
    xit "returns the space of the valid piece the player selects" do
      chess = Chess.new
      player = Player.new('name', 'black')
      space = chess.board.detect { |space| space.coordinate == [1,1] }
      expect(chess.select_piece(player)).to eql(space)
    end
  end

  describe "#select_new_position" do
    xit "returns the new position selected if a valid position in possible_moves: [1,6]" do
      chess = Chess.new
      player1 = Player.new('name', 'black')
      rook = Rook.new([1,3], "black")
      original_position = chess.board.detect { |space| space.coordinate == [1,3] }
      original_position.chess_piece = rook
      new_position = chess.board.detect { |space| space.coordinate == [1,6] }
      expect(chess.select_new_position(player1,original_position)).to eql(new_position)
    end
  end

  describe "#update_board" do
    it "returns the new board with enemy replaced by move" do
      chess = Chess.new
      player1 = Player.new('name', 'black')
      player2 = Player.new('name', 'white')
      rook = Rook.new([1,3], "black")
      original_position = chess.board.detect { |space| space.coordinate == [1,3] }
      original_position.chess_piece = rook
      new_position = chess.board.detect { |space| space.coordinate == [1,7] }
      expect(chess.update_board(new_position,original_position,player2)).to eql(chess.board)
    end
  end
end