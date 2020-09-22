
require 'pry'

class Chess
  attr_accessor :coordinates, :board

  def initialize()
    @coordinates = create_coordinates()
    @board = build_board(@coordinates)
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

  def build_board(coordinates)
    mapped_connections = []
    coordinates.each do |coordinate|
      mapped_connections.push(Space.new(coordinate))
    end
    return mapped_connections
  end

  def player_select(num)
    puts "\nPlayer #{num}, please type your name..."
    name = gets.chomp
    return Player.new(name, "black", @board) if num == "1"
    return Player.new(name, "white", @board) if num == "2"
  end

  def round(player, opponent)
    until move != nil
      original_position = select_piece(player)
      new_position = select_new_position(player, original_position)
    end
    new_board = update_board(new_position, original_position, opponent)
    puts display_board(new_board)
  end

  def select_piece(player)
    puts "\nChoose which piece you'd like to move:"
    loop do
      response = gets.chomp.split('').map { |string| string.to_i }
      requested_space = @board.detect { |space| space.coordinate == response }
      if requested_space.chess_piece != nil
        if requested_space.chess_piece.color == player.color
          return requested_space
        else
          puts "That's not your piece!"
        end
      else
        puts "There's no piece there!"
      end
    end
  end

  def select_new_position(player, original_position)
    piece = original_position.chess_piece.name
    single_moves = original_position.chess_piece.single_moves
    if piece == 'rook' || piece == 'bishop' || piece == 'queen'
      legal_moves = original_position.chess_piece.get_legal_moves_dir(single_moves)
      possible_moves = original_position.chess_piece.get_possible_moves_dir(legal_moves, @board, player)
    elsif piece == 'knight' || piece == 'king'
      legal_moves = original_position.chess_piece.get_legal_moves_nondir(single_moves)
      possible_moves = original_position.chess_piece.get_possible_moves_nondir(legal_moves, @board, player)
    end
    puts "\nChoose one of the following spaces to move this piece:"
    possible_moves.each { |space| puts "\t#{space}" }
    puts "\n\t\tOr type 'back' if you'd like to choose another piece to move"
    response = gets.chomp
    return nil if response.downcase == 'back'
    response = response.split('').map { |string| string.to_i }
    until possible_moves.any? { |space| space == response } do
      puts "\nPlease enter a valid space:"
      response = gets.chomp
      return nil if response.downcase == 'back'
      response = response.split('').map { |string| string.to_i }
    end
    new_position = @board.detect { |space| space.coordinate == response }
    return new_position
  end

  def update_board(new_position, original_position, opponent)
    opponent.remaining_pieces -= 1 if new_position.chess_piece != nil
    new_position.chess_piece = original_position.chess_piece
    new_position.chess_piece.position = new_position.coordinate
    original_position.chess_piece = nil
    return @board
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

  def get_legal_moves_dir(single_moves) #used for directional pieces (rook, bishop, queen)
    legal_moves = []
    directions = single_moves.each_slice(8).to_a
    directions.each do |direction|
      directional_moves = []
      direction.each do |move|
        new_x = @position[0] + move[0]
        new_y = @position[1] + move[1]
        if new_x < 1 || new_x > 8 || new_y < 1 || new_y > 8
          break if move == direction[0] #because there is no valid move in this direction 
        else
          directional_moves.push([new_x, new_y]) #because it is a valid move in this direction
        end
        legal_moves.push(directional_moves) if move == direction[-1]
      end
    end
    return legal_moves
  end

  def get_legal_moves_nondir(single_moves) #used for non-directional advanced pieces (knight, king)
    legal_moves = []
    single_moves.each do |move|
      new_x = @position[0] + move[0]
      new_y = @position[1] + move[1]
      break if new_x < 1 || new_x > 8 || new_y < 1 || new_y > 8
      legal_moves.push([new_x, new_y])
    end
    return legal_moves
  end

  def get_possible_moves_dir(legal_moves, board, player)
    legal_moves.each do |direction|
      direction.each_with_index do |move, index|
        space = board.detect { |space| space.coordinate == move }
        if space.chess_piece != nil
          if space.chess_piece.color != player.color #if the piece is an enemy piece
            direction.slice!(index+1, direction[index+1..-1].length) #add it to the list of possible moves
            break
          else
            direction.slice!(index, direction[index..-1].length)
            break
          end
        end
      end
    end
    return legal_moves.flatten(1)
  end

  def get_possible_moves_nondir(legal_moves, board, player)
    legal_moves.each_with_index do |move, index|
      space = board.detect { |space| space.coordinate == move }
      if space.chess_piece != nil && space.chess_piece.color == player.color
        legal_moves.delete_at(index) #add it to the list of possible moves
        break
      end
    end
    return legal_moves
  end

end

class Knight
  include ChessPiece
  attr_accessor :position, :color, :single_moves, :name

  def initialize(position, color)
    @position = position
    @color = color
    @single_moves = [
    [1,2],[2,1],[2,-1],[1,-2],[-1,-2],[-2,-1],[-2,1],[-1,2]
    ]
    @name = 'knight'
  end

end

class Bishop
  include ChessPiece
  attr_accessor :position, :color, :single_moves, :name

  def initialize(position, color)
    @position = position
    @color = color
    @single_moves = [
    [1,1],[2,2],[3,3],[4,4],[5,5],[6,6],[7,7],[8,8],
    [-1,1],[-2,2],[-3,3],[-4,4],[-5,5],[-6,6],[-7,7],[-8,8],
    [-1,-1],[-2,-2],[-3,-3],[-4,-4],[-5,-5],[-6,-6],[-7,-7],[-8,-8],
    [1,-1],[2,-2],[3,-3],[4,-4],[5,-5],[6,-6],[7,-7],[8,-8]
    ]
    @name = 'bishop'
  end

  def get_possible_moves()
    possible_moves = []
    legal_moves = get_legal_moves()
    #
  end


end

class Rook
  include ChessPiece
  attr_accessor :position, :color, :single_moves, :name

  def initialize(position, color)
    @position = position
    @color = color
    @single_moves = [
    [0,1],[0,2],[0,3],[0,4],[0,5],[0,6],[0,7],[0,8],
    [1,0],[2,0],[3,0],[4,0],[5,0],[6,0],[7,0],[8,0],
    [-1,0],[-2,0],[-3,0],[-4,0],[-5,0],[-6,0],[-7,0],[-8,0],
    [0,-1],[0,-2],[0,-3],[0,-4],[0,-5],[0,-6],[0,-7],[0,-8]
    ]
    @name = 'rook'
  end

end

class Pawn
  include ChessPiece
  attr_accessor :position, :color, :single_moves, :name

  def initialize(position, color)
    @position = position
    @color = color
    @single_moves = [0,1]
    @name = 'pawn'
  end

end

class Queen
  include ChessPiece
  attr_accessor :position, :color, :single_moves, :name

  def initialize(position, color)
    @position = position
    @color = color
    @single_moves = [
    [1,1],[2,2],[3,3],[4,4],[5,5],[6,6],[7,7],[8,8],
    [-1,1],[-2,2],[-3,3],[-4,4],[-5,5],[-6,6],[-7,7],[-8,8],
    [-1,-1],[-2,-2],[-3,-3],[-4,-4],[-5,-5],[-6,-6],[-7,-7],[-8,-8],
    [1,-1],[2,-2],[3,-3],[4,-4],[5,-5],[6,-6],[7,-7],[8,-8],
    [0,1],[0,2],[0,3],[0,4],[0,5],[0,6],[0,7],[0,8],
    [1,0],[2,0],[3,0],[4,0],[5,0],[6,0],[7,0],[8,0],
    [-1,0],[-2,0],[-3,0],[-4,0],[-5,0],[-6,0],[-7,0],[-8,0],
    [0,-1],[0,-2],[0,-3],[0,-4],[0,-5],[0,-6],[0,-7],[0,-8]
    ]
    @name = 'queen'
  end

end

class King
  include ChessPiece
  attr_accessor :position, :color, :single_moves, :name

  def initialize(position, color)
    @position = position
    @color = color
    @single_moves = [
    [1,1],[1,0],[1,-1],[0,-1],[-1,-1],[-1,0],[-1,1],[0,1]
    ]
    @name = 'king'
  end

end

=begin

game = Chess.new()
player1 = player_select('1')
player2 = player_select('2')
loop do
  game.round(player1, player2)
    break if player2.remaining_pieces.length == 0
  game.round(player2, player1)
    break if player1.remaining_pieces.length == 0
end

=end








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










