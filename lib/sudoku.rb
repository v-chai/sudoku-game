require_relative "./board.rb"

class Sudoku
    attr_reader :board, :position, :value, :previous_guess, :undo

    def initialize
        file = self.get_file_name
        if Board.new(file)
            @board = Board.new(file)
        else
            puts "Cannot find file. Please load it to a txt file and save in `puzzles` folder"
        end
        puts "Do you want to flag invalid duplicates? y/n >> "
        flag = gets.chomp
        if ["y","yes","Y","YES","Yes"].include?(flag)
            @board.flag_dupes = true
        end

        @previous_guess = nil
    end

    def get_file_name
        puts "Please enter the name of the txt file you want to open from the `puzzles` folder"
        filename = gets.chomp
        if filename.end_with?(".txt")
            "./puzzles/#{filename}"
        else
            puts "Please enter a .txt filename with the extension (include .txt at the end)"
        end
    end

    def play
        system("clear")
        @board.render
        until @board.solved? 
            self.user_prompt
            self.update_board(@position, @value)
            if @board.flag_dupes
                @board.flag_dupes_for_board
            end
            @board.render
        end

        puts "Game over! You solved the puzzle!"

    end

    def update_board(position, value)
        @board[position] = value
    end

    def user_prompt
        @position = self.get_coordinates
        @value = self.get_new_value
    end

    def get_coordinates
        puts "Please enter the row and column number for the space you want to change."
        puts "You can also type `undo` to undo your last move"
        print "E.g., `0,1` for the first row, second column >> "
        position = gets.chomp
        @undo = false
        if position == "undo"
            @undo = true
            position = @previous_guess[0]
        else
            position = position.split(",").map!(&:to_i)
            until self.valid_coords?(position)
                position = gets.chomp.split(",")
                position = position.map!(&:to_i)
                if !self.valid_coords?(position)
                    print "Enter valid coordinates like 0,0 >> "
                end
            end
            @previous_guess = [position, @board[position].value]
        end
        position 
    end

    def get_new_value
        
        if @undo
            @undo = false
            return @previous_guess[1]
            
        else
            value = nil
            until value && (0..9).to_a.include?(value)
                print "Please enter the value (1-9, or 0 to erase) you want to try in this position >> "
                value = gets.chomp.to_i
            end
        end
        value
    end

    def valid_coords?(coordinates)
        coordinates.is_a?(Array) &&
        coordinates.length == 2 && 
        coordinates.all? {|coordinate| (0..8).to_a.include?(coordinate)}
    end


end

if __FILE__ == $PROGRAM_NAME
    game = Sudoku.new
    game.play
end