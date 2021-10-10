require_relative "./tile.rb"
require "set"

class Board
    attr_reader :grid, :ideal, :splits
    attr_accessor :flag_dupes

    def initialize(grid)
        @grid = Board.grid_from_file(grid)
        @ideal = [1,2,3,4,5,6,7,8,9].to_set
        @splits = [[0, 3], [3, 6], [6, 9]]
        @flag_dupes = false 
    end

    def self.grid_from_file(file)
        grid = []
        File.readlines(file).each do |line|
            row = []
            line.chomp.each_char do |num|
                row << Tile.new(num)
            end
   
            grid << row
        end
        grid
    end

    def render
        system("clear")
        linebreak = "   -----------------------------------"
        system("clear")
        
        
        puts "    #{[0,1,2," ",3,4,5," ",6,7,8].join('  ')}"
        puts linebreak
        grid.each_with_index do |row, i|
            values = row.each {|tile| tile.to_s }.to_a.dup
            if values.none? {|val| val == "|"}
                values.insert(3, "|")
                values.insert(7, "|")
                values.insert(11, "|")
            end
            if [3,6].include?(i)
                puts linebreak
                puts "#{i} | #{values.join('  ')}"
            else
                puts "#{i} | #{values.join('  ')}"
            end
        end
        puts linebreak
    end

    def [](position)
        @grid[position[0]][position[1]]
    end

    def []=(position, value)
        if @grid[position[0]][position[1]].given == false
            @grid[position[0]][position[1]].value = value
        else
            puts
            puts "This item was provided in the puzzle. You cannot change it."
            sleep 2
        end
    end

    def solved?
        self.get_sequence_values(self.get_rows).all? { |row| self.seq_solved?(row) } &&
        self.get_sequence_values(self.get_cols).all? { |col| self.seq_solved?(col) } &&
        self.get_sequence_values(self.get_squares).all? { |sq| self.seq_solved?(sq) }
    end

    def seq_solved?(seq)
        seq.to_set == @ideal
    end

    def get_sequence_values(tile_sequences)
        value_seqs = []
        tile_sequences.each do |tile_seq|
            seq_vals = []
            tile_seq.each do |tile|
                seq_vals << tile.value
            end
            value_seqs << seq_vals
        end
        value_seqs
    end

    def get_rows
        @grid.each {|row| row}
    end

    def get_cols
        cols = []
        (0...9).each do |j|
            col = []
            (0...9).each do |i|
                col << @grid[i][j]
            end
            cols << col
        end
        cols
    end

    def get_squares
        squares = []
        @splits.each do |col_split| 
            @splits.each do |row_split|
                square = []
                (row_split[0]...row_split[1]).each do |i|
                    (col_split[0]...col_split[1]).each do |j|
                        square << @grid[i][j]
                    end
                end
                squares << square
            end
        end
        squares
    end

    def seq_dups(seq)
        seq.select { |ele| seq.count(ele) > 1 && ele != 0}
    end

    def find_dupes(seqs_of_9)
        all_dupes = []
        self.get_sequence_values(seqs_of_9).each do |seq_of_9| 
            dupes = self.seq_dups(seq_of_9) 
            all_dupes << dupes
        end
        all_dupes
    end

    def set_dupes(seqs_of_9)
        all_dupes = self.find_dupes(seqs_of_9)
        seqs_of_9.each_with_index do |seq_of_9, i|
            seq_of_9.each do |tile|
                if all_dupes[i].include?(tile.value)
                    tile.dupe = true
                end
            end
        end
    end

    def flag_dupes_for_board
        self.set_dupes(self.get_rows)
        self.set_dupes(self.get_cols)
        self.set_dupes(self.get_squares)
    end


end