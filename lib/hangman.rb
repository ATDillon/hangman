# Holds script for the game hangman
class Hangman
  attr_reader :guessed

  private

  attr_accessor :word
  attr_writer :guessed
  attr_reader :player, :dictionary

  def initialize(player:)
    @player = player
    @dictionary = File.readlines('5desk.txt')
    @word = word_picker
    @guessed = []
  end

  def word_picker
    loop do
      new_word = dictionary[Random.rand(dictionary.length)].chomp
      break new_word unless new_word.length < 5 || new_word.length > 12
    end
  end

  def letter_hider(string)
    result = string.split('').map do |letter|
      if guessed.include?(letter.downcase)
        letter
      else
        '-'
      end
    end
    result.join('')
  end

  def word_display(string)
    puts letter_hider(string)
  end
end
