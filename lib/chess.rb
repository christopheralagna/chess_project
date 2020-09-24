
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
    return Player.new(name, "black") if num == "1"
    return Player.new(name, "white") if num == "2"
  end

  def round(player, opponent)
    puts display_board(@board)
    new_position = nil
    until new_position != nil
      original_position = select_piece(player)
      possible_moves = get_possible_moves(player, original_position)
      new_position = select_new_position(possible_moves)
    end
    new_board = update_board(new_position, original_position, opponent)
  end

  def select_piece(player)
    puts "\nSelect a space using 'xy' coordinates: inputs like '11', '12','45','78', etc..."
    puts "\n#{player.name}, choose which piece you'd like to move:\n\n"
    loop do
      response = gets.chomp.split('').map { |string| string.to_i }
      requested_space = @board.detect { |space| space.coordinate == response }
      if requested_space.chess_piece.name != 'blank'
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

  def get_possible_moves(player, original_position)
    piece = original_position.chess_piece.name
    single_moves = original_position.chess_piece.single_moves
    if piece == 'rook' || piece == 'bishop' || piece == 'queen'
      legal_moves = original_position.chess_piece.get_legal_moves_dir(single_moves, player)
      possible_moves = original_position.chess_piece.get_possible_moves_dir(legal_moves, @board, player)
    elsif piece == 'knight' || piece == 'king' || piece == 'pawn'
      if piece == 'pawn'
        possible_moves = original_position.chess_piece.get_possible_moves_pawn(single_moves, @board, player)
      else
        legal_moves = original_position.chess_piece.get_legal_moves_nondir(single_moves, player)
        possible_moves = original_position.chess_piece.get_possible_moves_nondir(legal_moves, @board, player)
      end
    end
  end

  def select_new_position(possible_moves)
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
    opponent.remaining_pieces -= 1 if new_position.chess_piece.name != 'blank'
    new_position.chess_piece = original_position.chess_piece
    new_position.chess_piece.position = new_position.coordinate
    original_position.chess_piece = Blank.new
    return @board
  end

  def display_board(board)
    "
      _ _ _ _ _ _ _ _
    8|#{board[7].chess_piece.symbol}|#{board[15].chess_piece.symbol}|#{board[23].chess_piece.symbol}|#{board[31].chess_piece.symbol}|#{board[39].chess_piece.symbol}|#{board[47].chess_piece.symbol}|#{board[55].chess_piece.symbol}|#{board[63].chess_piece.symbol}|
    7|#{board[6].chess_piece.symbol}|#{board[14].chess_piece.symbol}|#{board[22].chess_piece.symbol}|#{board[30].chess_piece.symbol}|#{board[38].chess_piece.symbol}|#{board[46].chess_piece.symbol}|#{board[54].chess_piece.symbol}|#{board[62].chess_piece.symbol}|
    6|#{board[5].chess_piece.symbol}|#{board[13].chess_piece.symbol}|#{board[21].chess_piece.symbol}|#{board[29].chess_piece.symbol}|#{board[37].chess_piece.symbol}|#{board[45].chess_piece.symbol}|#{board[53].chess_piece.symbol}|#{board[61].chess_piece.symbol}|
    5|#{board[4].chess_piece.symbol}|#{board[12].chess_piece.symbol}|#{board[20].chess_piece.symbol}|#{board[28].chess_piece.symbol}|#{board[36].chess_piece.symbol}|#{board[44].chess_piece.symbol}|#{board[52].chess_piece.symbol}|#{board[60].chess_piece.symbol}|
    4|#{board[3].chess_piece.symbol}|#{board[11].chess_piece.symbol}|#{board[19].chess_piece.symbol}|#{board[27].chess_piece.symbol}|#{board[35].chess_piece.symbol}|#{board[43].chess_piece.symbol}|#{board[51].chess_piece.symbol}|#{board[59].chess_piece.symbol}|
    3|#{board[2].chess_piece.symbol}|#{board[10].chess_piece.symbol}|#{board[18].chess_piece.symbol}|#{board[26].chess_piece.symbol}|#{board[34].chess_piece.symbol}|#{board[42].chess_piece.symbol}|#{board[50].chess_piece.symbol}|#{board[58].chess_piece.symbol}|
    2|#{board[1].chess_piece.symbol}|#{board[9].chess_piece.symbol}|#{board[17].chess_piece.symbol}|#{board[25].chess_piece.symbol}|#{board[33].chess_piece.symbol}|#{board[41].chess_piece.symbol}|#{board[49].chess_piece.symbol}|#{board[57].chess_piece.symbol}|
    1|#{board[0].chess_piece.symbol}|#{board[8].chess_piece.symbol}|#{board[16].chess_piece.symbol}|#{board[24].chess_piece.symbol}|#{board[32].chess_piece.symbol}|#{board[40].chess_piece.symbol}|#{board[48].chess_piece.symbol}|#{board[56].chess_piece.symbol}|
      1 2 3 4 5 6 7 8
    "  
  end

end

class Space
  attr_accessor :coordinate, :chess_piece

  def initialize(coordinate)
    @coordinate = coordinate
    @chess_piece = generate_piece(coordinate)
  end

  def generate_piece(coordinate)
    
    return Rook.new(coordinate, 'black', '♖') if coordinate == [1,1]
    return Rook.new(coordinate, 'white', '♜') if coordinate == [1,8]
    return Knight.new(coordinate, 'black', '♘') if coordinate == [2,1]
    return Knight.new(coordinate, 'white', '♞') if coordinate == [2,8]
    return Bishop.new(coordinate, 'black', '♗') if coordinate == [3,1]
    return Bishop.new(coordinate, 'white', '♝') if coordinate == [3,8]
    return King.new(coordinate, 'black', '♕') if coordinate == [4,1]
    return King.new(coordinate, 'white', '♛') if coordinate == [4,8]
    return Queen.new(coordinate, 'black', '♔') if coordinate == [5,1]
    return Queen.new(coordinate, 'white', '♚') if coordinate == [5,8]
    return Bishop.new(coordinate, 'black', '♗') if coordinate == [6,1]
    return Bishop.new(coordinate, 'white', '♝') if coordinate == [6,8]
    return Knight.new(coordinate, 'black', '♘') if coordinate == [7,1]
    return Knight.new(coordinate, 'white', '♞') if coordinate == [7,8]
    return Rook.new(coordinate, 'black', '♖') if coordinate == [8,1]
    return Rook.new(coordinate, 'white', '♜') if coordinate == [8,8]

    for i in 1..8
      return Pawn.new(coordinate, 'black', '♙') if coordinate == [i,2]
      return Pawn.new(coordinate, 'white', '♟') if coordinate == [i,7]
    end

    return Blank.new
  
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

  def get_legal_moves_dir(single_moves, player) #used for directional pieces (rook, bishop, queen)
    legal_moves = []
    directions = single_moves.each_slice(8).to_a
    directions.each do |direction|
      directional_moves = []
      direction.each do |move|
        new_x = @position[0] + move[0]
        if player.color == 'black'
          new_y = @position[1] + move[1]
        elsif player.color == 'white'
          new_y = @position[1] - move[1]
        end
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

  def get_legal_moves_nondir(single_moves, player) #used for non-directional advanced pieces (knight, king)
    legal_moves = []
    single_moves.each do |move|
      new_x = @position[0] + move[0]
      if player.color == 'black'
        new_y = @position[1] + move[1]
      elsif player.color == 'white'
        new_y = @position[1] - move[1]
      end
      next if new_x < 1 || new_x > 8 || new_y < 1 || new_y > 8
      legal_moves.push([new_x, new_y])
    end
    return legal_moves
  end

  def get_possible_moves_dir(legal_moves, board, player)
    legal_moves.each do |direction|
      direction.each_with_index do |move, index|
        space = board.detect { |space| space.coordinate == move }
        if space.chess_piece.name != 'blank'
          if space.chess_piece.color != player.color && space.chess_piece.color != 'none'  #if the piece is an enemy piece
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
    possible_moves = []
    legal_moves.each do |move|
      space = board.detect { |space| space.coordinate == move }
      if space.chess_piece.color != player.color #!!space.chess_piece != nil &&
        possible_moves.push(move) #add it to the list of possible moves
      end
    end
    return possible_moves
  end

end

class Blank
  attr_accessor :symbol, :name, :color

  def initialize()
    @symbol = " "
    @name = 'blank'
    @color = 'none'
  end

end

class Knight
  include ChessPiece
  attr_accessor :position, :color, :symbol, :single_moves, :name

  def initialize(position, color, symbol)
    @position = position
    @color = color
    @symbol = symbol
    @single_moves = [
    [1,2],[2,1],[2,-1],[1,-2],[-1,-2],[-2,-1],[-2,1],[-1,2]
    ]
    @name = 'knight'
  end

end

class Bishop
  include ChessPiece
  attr_accessor :position, :color, :symbol, :single_moves, :name

  def initialize(position, color, symbol)
    @position = position
    @color = color
    @symbol = symbol
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
  attr_accessor :position, :color, :symbol, :single_moves, :name

  def initialize(position, color, symbol)
    @position = position
    @color = color
    @symbol = symbol
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
  attr_accessor :position, :color, :symbol, :single_moves, :name

  def initialize(position, color, symbol)
    @position = position
    @color = color
    @symbol = symbol
    @single_moves = [[-1,1],[0,1],[1,1]]
    @name = 'pawn'
  end

  def get_possible_moves_pawn(single_moves, board, player)

    legal_moves = []
    possible_moves = []

    single_moves.each do |move|
      new_x = @position[0] + move[0]
      if player.color == 'black'
        new_y = @position[1] + move[1]
      elsif player.color == 'white'
        new_y = @position[1] - move[1]
      end
      legal_moves.push([new_x, new_y])
      next if new_x < 1 || new_x > 8 || new_y < 1 || new_y > 8
      possible_moves.push([new_x, new_y])
    end

    left_move = legal_moves[0]
    forward_move = legal_moves[1]
    right_move = legal_moves[2]

    if possible_moves.include?(left_move)
      left_capture_space = board.detect { |space| space.coordinate == left_move }
      possible_moves.delete(left_move) if left_capture_space.chess_piece.name == 'blank'
    end

    if possible_moves.include?(forward_move)
      forward_space = board.detect { |space| space.coordinate == forward_move }
      possible_moves.delete(forward_move) if forward_space.chess_piece.name != 'blank'
    end
    
    if possible_moves.include?(right_move)
      right_capture_space = board.detect { |space| space.coordinate == right_move }
      possible_moves.delete(right_move) if right_capture_space.chess_piece.name == 'blank'
    end

    return possible_moves

  end

end

class Queen
  include ChessPiece
  attr_accessor :position, :color, :symbol, :single_moves, :name

  def initialize(position, color, symbol)
    @position = position
    @color = color
    @symbol = symbol
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
  attr_accessor :position, :color, :symbol, :single_moves, :name

  def initialize(position, color, symbol)
    @position = position
    @color = color
    @symbol = symbol
    @single_moves = [
    [1,1],[1,0],[1,-1],[0,-1],[-1,-1],[-1,0],[-1,1],[0,1]
    ]
    @name = 'king'
  end

end

game = Chess.new()
player1 = game.player_select('1')
player2 = game.player_select('2')
loop do
  game.round(player1, player2)
    break if player2.remaining_pieces == 0
  game.round(player2, player1)
    break if player1.remaining_pieces == 0
end
