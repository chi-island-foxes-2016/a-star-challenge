class PriorityQueue
  def initialize
    @queue = {}
  end

  def add(element, priority)
    @queue[element] = priority
  end

  def pull
    top = @queue.min_by { |k,v| v } .first
    @queue.delete(top)
    top
  end

  def empty?
    @queue.empty?
  end
end

$tried = 0

class AStarSolver
  @@allowed_moves = [[-1,0], #up
                     [0, 1], #right
                     [1, 0], #down
                     [0,-1]] #left

  def initialize(filename)
    @board = parse_file(filename)
    @start = find_space("o")
    @end = find_space("*")
    @frontier = PriorityQueue.new()
    @frontier.add(@start, 0)
    @came_from = {@start => nil}
    @cost_so_far = {@start => 0}
    solve
    draw_path(get_path)
    puts "Tried #{$tried} squares."
  end

  def heuristic(pos)
    (@end[0]-pos[0]).abs + (@end[1]-pos[1]).abs
  end

  def parse_file(filename)
    File.open(filename).map {|line| line.chomp}
  end

  def find_space(string)
    @board.each_index do |row|
      col = @board[row].index(string)
      return row, col if col
    end
  end

  def solve
    until @frontier.empty?
      pos = @frontier.pull
      break if pos == @end
      $tried += 1
      extend_frontier(pos)
    end
  end

  def get_path
    backwards = []
    prev = @end
    while @came_from[prev]
      backwards << prev
      prev = @came_from[prev]
    end
    backwards.reverse
  end

  def draw_path(path)
    draw_board
    path.each do |square|
      sleep(0.05)
      @board[square[0]][square[1]] = "x"
      draw_board
    end
  end

  def draw_board
    print "\e[2J\e[f"
    puts @board.join("\n")
  end

  def extend_frontier(pos)
    new_cost = @cost_so_far[pos] + 1
    neighbors(pos).each do |neighbor|
      if !(@cost_so_far.keys.include? neighbor) or (new_cost < @cost_so_far[neighbor])
        @frontier.add(neighbor, new_cost + heuristic(neighbor))
        @cost_so_far[neighbor] = new_cost
        @came_from[neighbor] = pos
      end
    end
  end

  def neighbors(pos)
    squares = @@allowed_moves.map {|move| [move[0]+pos[0], move[1]+pos[1]]}
    squares.select do |square|
      ((0...@board.length).include? square[0]) and
      ((0...@board[0].length).include? square[1]) and
      (@board[square[0]][square[1]] != '#') #check last, to avoid nil
    end
  end
end

AStarSolver.new(ARGV[0])