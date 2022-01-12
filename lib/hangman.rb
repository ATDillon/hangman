# Holds script for the game hangman
class Hangman
  attr_accessor :word
  attr_reader :player, :dictionary

  def initialize(player:)
    @player = player
    @dictionary = File.readlines('5desk.txt')
    @word = word_picker
    @guessed = []
  end

  def word_picker
    loop do
      new_word = dictionary[Random.rand(dictionary.length)]
      break new_word unless new_word.length < 5 || new_word.length > 12
    end
  end
end
