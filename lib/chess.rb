
require 'pry'

class Chess
  attr_accessor :coordinates, :graph

  def initialize()
    @coordinates = create_coordinates()
    @graph = build_graph(@coordinates)
  end

  def create_coordinates()
    coordinates = []
    for i in 1..8 do
      for j in 1..8 do
        coordinates.push([i,j])
      end
    end
    return coordinates
  end

  def build_graph(coordinates)
    mapped_connections = []
    coordinates.each do |coordinate|
      mapped_connections.push(Space.new(coordinate))
    end
    return mapped_connections
  end

  def generate_pieces(player)
    rook1 = Rook.new
    space = @graph.detect { |space| space.coordinate == [1,1] } if player.color == 'black'
    space = @graph.detect { |space| space.coordinate == [1,8] } if player.color == 'white'
    space.chess_piece = rook1
  
  end

  def player_select(num)
    puts "\nPlayer #{num}, please type your name..."
    name = gets.chomp
    return Player.new(name, "black", @graph) if num == "1"
    return Player.new(name, "white", @graph) if num == "2"
  end

  def round()

  end

end

class Space
  attr_accessor :coordinate, :chess_piece

  def initialize(coordinate)
    @coordinate = coordinate
    @chess_piece = generate_piece(coordinate)
  end

  def generate_piece(coordinate)
    
    return Rook.new(coordinate, 'black') if coordinate == [1,1]
    return Rook.new(coordinate, 'white') if coordinate == [1,8]
    return Knight.new(coordinate, 'black') if coordinate == [2,1]
    return Knight.new(coordinate, 'white') if coordinate == [2,8]
    return Bishop.new(coordinate, 'black') if coordinate == [3,1]
    return Bishop.new(coordinate, 'white') if coordinate == [3,8]
    return King.new(coordinate, 'black') if coordinate == [4,1]
    return King.new(coordinate, 'white') if coordinate == [4,8]
    return Queen.new(coordinate, 'black') if coordinate == [5,1]
    return Queen.new(coordinate, 'white') if coordinate == [5,8]
    return Bishop.new(coordinate, 'black') if coordinate == [6,1]
    return Bishop.new(coordinate, 'white') if coordinate == [6,8]
    return Knight.new(coordinate, 'black') if coordinate == [7,1]
    return Knight.new(coordinate, 'white') if coordinate == [7,8]
    return Rook.new(coordinate, 'black') if coordinate == [8,1]
    return Rook.new(coordinate, 'white') if coordinate == [8,8]

    for i in 1..8
      return Pawn.new(coordinate, 'black') if coordinate == [i,2]
      return Pawn.new(coordinate, 'white') if coordinate == [i,7]
    end

    return nil
  
  end
end

class Player
  attr_accessor :remaining_pieces, :name, :color

  def initialize(name, color)
    @name = name
    @color = color
    @remaining_pieces = 16
  end

end

module ChessPiece

  def get_possible_moves()
    possible_moves = []
    @single_moves.each do |move|
      new_x = @coordinate[0] + move[0]
      new_y = @coordinate[1] + move[1]
      unless new_x < 0 || new_x > 7 || new_y < 0 || new_y > 7 || 
        possible_moves.push([new_x, new_y])
      end
    end
    return possible_moves
  end

end

class Knight
  include ChessPiece
  attr_accessor :position, :single_moves, :possible_moves

  def initialize(position, color)
    @position = position
    @color = color
    @single_moves = [
    [1,2],[2,1],[2,-1],[1,-2],[-1,-2],[-2,-1],[-2,1],[-1,2]
    ]
  end

end

class Bishop
  include ChessPiece
  attr_accessor :position, :single_moves, :possible_moves

  def initialize(position, color)
    @position = position
    @color = color
    @single_moves = [
    [1,1],[2,2],[3,3],[4,4],[5,5],[6,6],[7,7],[8,8],
    [-1,1],[-2,2],[-3,3],[-4,4],[-5,5],[-6,6],[-7,7],[-8,8]
    [-1,-1],[-2,-2],[-3,-3],[-4,-4],[-5,-5],[-6,-6],[-7,-7],[-8,-8]
    [1,-1],[2,-2],[3,-3],[4,-4],[5,-5],[6,-6],[7,-7],[8,-8]
    ]
  end

end

class Rook
  include ChessPiece
  attr_accessor :position, :single_moves, :possible_moves

  def initialize(position, color)
    @position = position
    @color = color
    @single_moves = [
    [0,1],[0,2],[0,3],[0,4],[0,5],[0,6],[0,7],[0,8],
    [1,0],[2,0],[3,0],[4,0],[5,0],[6,0],[7,0],[8,0]
    [-1,0],[-2,0],[-3,0],[-4,0],[-5,0],[-6,0],[-7,0],[-8,0]
    [0,-1],[0,-2],[0,-3],[0,-4],[0,-5],[0,-6],[0,-7],[0,-8]
    ]
  end

end

class Pawn
  include ChessPiece
  attr_accessor :position, :single_moves, :possible_moves

  def initialize(position, color)
    @position = position
    @color = color
    @single_moves = [0,1]
  end

end

class Queen
  include ChessPiece
  attr_accessor :position, :single_moves, :possible_moves

  def initialize(position, color)
    @position = position
    @color = color
    @single_moves = [
    [1,1],[2,2],[3,3],[4,4],[5,5],[6,6],[7,7],[8,8],
    [-1,1],[-2,2],[-3,3],[-4,4],[-5,5],[-6,6],[-7,7],[-8,8]
    [-1,-1],[-2,-2],[-3,-3],[-4,-4],[-5,-5],[-6,-6],[-7,-7],[-8,-8]
    [1,-1],[2,-2],[3,-3],[4,-4],[5,-5],[6,-6],[7,-7],[8,-8]
    [0,1],[0,2],[0,3],[0,4],[0,5],[0,6],[0,7],[0,8],
    [1,0],[2,0],[3,0],[4,0],[5,0],[6,0],[7,0],[8,0]
    [-1,0],[-2,0],[-3,0],[-4,0],[-5,0],[-6,0],[-7,0],[-8,0]
    [0,-1],[0,-2],[0,-3],[0,-4],[0,-5],[0,-6],[0,-7],[0,-8]
    ]
  end

end

class King
  include ChessPiece
  attr_accessor :position, :single_moves, :possible_moves

  def initialize(position, color)
    @position = position
    @color = color
    @single_moves = [
    [1,1],[1,0],[1,-1],[0,-1],[-1,-1],[-1,0],[-1,1],[0,1]
    ]
  end

end

game = Chess.new()
player1 = player_select('1')
player2 = player_select('2')
game.generate_pieces(player1)
game.generate_pieces(player2)
loop do
  game.round(player1)
    break if player2.remaining_pieces.length == 0
  game.round(player2)
    break if player1.remaining_pieces.length == 0
end








"
   _ _ _ _ _ _ _ _
8 |♜|♞|♝|♛|♚|♝|♞|♜|
7 |♟|♟|♟|♟|♟|♟|♟|♟|
6 |_|_|_|_|_|_|_|_|
5 |_|_|_|_|_|_|_|_|
4 |_|_|_|_|_|_|_|_|
3 |_|_|_|_|_|_|_|_|
2 |♙|♙|♙|♙|♙|♙|♙|♙|
1 |♖|♘|♗|♕|♔|♗|♘|♖|
   A B C D E F G H
"  

"
   _ _ _ _ _ _ _ _
8 |#{}|#{}|#{}|#{}|#{}|#{}|#{}|#{}|
7 |#{}|#{}|#{}|#{}|#{}|#{}|#{}|#{}|
6 |#{}|#{}|#{}|#{}|#{}|#{}|#{}|#{}|
5 |#{}|#{}|#{}|#{}|#{}|#{}|#{}|#{}|
4 |#{}|#{}|#{}|#{}|#{}|#{}|#{}|#{}|
3 |#{}|#{}|#{}|#{}|#{}|#{}|#{}|#{}|
2 |#{}|#{}|#{}|#{}|#{}|#{}|#{}|#{}|
1 |#{}|#{}|#{}|#{}|#{}|#{}|#{}|#{}|
   A B C D E F G H
"  

"
nil -> _
"










