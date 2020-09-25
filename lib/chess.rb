
require 'pry'
require 'json'

class Chess
  attr_accessor :coordinates, :board

  def initialize(coordinates = create_coordinates(), board = build_board(coordinates))
    @coordinates = coordinates
    @board = board
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
    return Player.new(name, "black", true) if num == "1"
    return Player.new(name, "white", false) if num == "2"
  end

  def round(player, opponent)
    puts display_board(@board)
    new_position = nil
    until new_position != nil
      original_position = select_piece(player, opponent)
      possible_moves = get_possible_moves(player, original_position)
      new_position = select_new_position(possible_moves)
    end
    @board = update_board(new_position, original_position, opponent)
    return true if opponent.remaining_pieces == 0
  end

  def select_piece(player, opponent)
    puts "\nSelect a space using 'xy' coordinates: inputs like '11', '12','45','78', etc..."
    puts "\n#{player.name}, choose which piece you'd like to move:"
    puts "\t\tOr type 'save' if you'd like to return to your game another time."
    loop do
      response = gets.chomp
      save_game(player, opponent) if response == 'save'
      response = response.split('').map { |string| string.to_i }
      until @board.any? { |space| space.coordinate == response } do
        puts "please enter a valid space."
        response = gets.chomp
        save_game(player, opponent) if response == 'save'
        response = response.split('').map { |string| string.to_i }
      end
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

  def display_winner(player)
    puts "\nCongratulations #{player.name}: You Win!"
    sleep(3)
    puts "\nWould you like to play again?\n"
    response = gets.chomp
    until response == 'yes' || response == 'no'
      puts "\ntype 'yes' or 'no'\n"
      response = gets.chomp
    end
    return false if response == 'no'
    return true if response == 'yes'
  end

  def request_load_game?(player1, player2)
    puts "\n\nWelcome to Chess, #{player1.name} and #{player2.name}!"
    sleep(1)
    puts "\nEnter 'new' if you would like to start a new game."
    puts "Enter 'load' if you would like to load an previous game."
    response = gets.chomp
    until response == 'new' || response == 'load'
      puts "\nPlease enter a valid response."
      response = gets.chomp
    end
    return true if response == 'load'
    return false if response == 'new'
  end

  def self.load()
    string = File.open('save.txt', 'r').readlines.join('')
    data = JSON.load(string)

    board = []
    data[0]['board'].each do |space|
      coordinate = space[0]
      if space[1] == 'blank'
        chess_piece = Blank.new
      else
        if space[4] == 'knight'
          chess_piece = Knight.new(space[1], space[2], space[3])
        elsif space[4] == 'rook'
          chess_piece = Rook.new(space[1], space[2], space[3])
        elsif space[4] == 'bishop'
          chess_piece = Bishop.new(space[1], space[2], space[3])
        elsif space[4] == 'pawn'
          chess_piece = Pawn.new(space[1], space[2], space[3])
        elsif space[4] == 'king'
          chess_piece = King.new(space[1], space[2], space[3])
        elsif space[4] == 'queen'
          chess_piece = Queen.new(space[1], space[2], space[3])
        end
      end
      board.push(Space.new(coordinate, chess_piece))
    end

    resumed_game = self.new(data[0]['coordinates'], board)
    resumed_player1 = Player.new(data[1]['name'], data[1]['color'], data[1]['turn'], data[1]['remaining_pieces'], data[1]['wins'])
    resumed_player2 = Player.new(data[2]['name'], data[2]['color'], data[2]['turn'], data[2]['remaining_pieces'], data[2]['wins'])
    save_data = [resumed_game, resumed_player1, resumed_player2]
    return save_data
  end

  def save_game(player, opponent)
    board_data = []
    @board.each do |space| 
      data = []
      data.push(space.coordinate)
      if space.chess_piece.name == 'blank'
        data.push('blank')
      else
        data.push(space.chess_piece.position)
        data.push(space.chess_piece.color)
        data.push(space.chess_piece.symbol)
        data.push(space.chess_piece.name)
      end
      board_data.push(data)
    end

    string = JSON.dump(
      [
        {
          :coordinates => @coordinates,
          :board => board_data
        },
        {
          :name => player.name,
          :color => player.color,
          :turn => player.turn,
          :remaining_pieces => player.remaining_pieces,
          :wins => player.wins
        },
        {
          :name => opponent.name,
          :color => opponent.color,
          :turn => opponent.turn,
          :remaining_pieces => opponent.remaining_pieces,
          :wins => opponent.wins
        }
      ])

    File.write('save.txt', string)
    puts "\n\nThanks for now!\n\n"
    exit
  end

end

class Space
  attr_accessor :coordinate, :chess_piece

  def initialize(coordinate, chess_piece = generate_piece(coordinate))
    @coordinate = coordinate
    @chess_piece = chess_piece
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
  attr_accessor :name, :color, :turn, :remaining_pieces, :wins

  def initialize(name, color, turn, remaining_pieces = 16, wins = false)
    @name = name
    @color = color
    @turn = turn
    @remaining_pieces = remaining_pieces
    @wins = wins
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

  def initialize(position, color, symbol, name = 'bishop')
    @position = position
    @color = color
    @symbol = symbol
    @name = name
    @single_moves = [
    [1,1],[2,2],[3,3],[4,4],[5,5],[6,6],[7,7],[8,8],
    [-1,1],[-2,2],[-3,3],[-4,4],[-5,5],[-6,6],[-7,7],[-8,8],
    [-1,-1],[-2,-2],[-3,-3],[-4,-4],[-5,-5],[-6,-6],[-7,-7],[-8,-8],
    [1,-1],[2,-2],[3,-3],[4,-4],[5,-5],[6,-6],[7,-7],[8,-8]
    ]
  end

end

class Rook
  include ChessPiece
  attr_accessor :position, :color, :symbol, :single_moves, :name

  def initialize(position, color, symbol, name = 'rook')
    @position = position
    @color = color
    @symbol = symbol
    @name = name
    @single_moves = [
    [0,1],[0,2],[0,3],[0,4],[0,5],[0,6],[0,7],[0,8],
    [1,0],[2,0],[3,0],[4,0],[5,0],[6,0],[7,0],[8,0],
    [-1,0],[-2,0],[-3,0],[-4,0],[-5,0],[-6,0],[-7,0],[-8,0],
    [0,-1],[0,-2],[0,-3],[0,-4],[0,-5],[0,-6],[0,-7],[0,-8]
    ]
  end

end

class Pawn
  include ChessPiece
  attr_accessor :position, :color, :symbol, :single_moves, :name

  def initialize(position, color, symbol, name = 'pawn')
    @position = position
    @color = color
    @symbol = symbol
    @name = name
    @single_moves = [[-1,1],[0,1],[1,1]]
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

  def initialize(position, color, symbol, name = 'queen')
    @position = position
    @color = color
    @symbol = symbol
    @name = name
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
  end

end

class King
  include ChessPiece
  attr_accessor :position, :color, :symbol, :single_moves, :name

  def initialize(position, color, symbol, name = 'king')
    @position = position
    @color = color
    @symbol = symbol
    @name = name
    @single_moves = [
    [1,1],[1,0],[1,-1],[0,-1],[-1,-1],[-1,0],[-1,1],[0,1]
    ]
  end

end

new_game = true
while new_game == true
  game = Chess.new()
  player1 = game.player_select('1')
  player2 = game.player_select('2')
  load_request = game.request_load_game?(player1, player2)
  if load_request == true
    save_data = Chess.load
    game = save_data[0]
    if save_data[1].turn
      player1 = save_data[2]
      player2 = save_data[1]
    elsif save_data[2].turn
      player1 = save_data[1]
      player2 = save_data[2]
    end
  end
  loop do
    if player1.turn
      player1.wins = game.round(player1, player2)
      player2.turn = true
      player1.turn = false
      break if player1.wins == true
    end
    if player2.turn
      player2.wins = game.round(player2, player1)
      player1.turn = true
      player2.turn = false
      break if player2.wins == true
    end
  end
  new_game = game.display_winner(player1) if player1.wins
  new_game = game.display_winner(player2) if player2.wins
  puts "\nThanks for playing!\n\n" if new_game == false
end
