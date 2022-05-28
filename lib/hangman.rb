require_relative 'player'

# Holds script for the game hangman
class Hangman
  attr_reader :guessed

  private

  attr_accessor :word, :tries
  attr_writer :guessed
  attr_reader :player, :dictionary

  def initialize(player:)
    @player = player
    @dictionary = File.readlines('google-10000-english-no-swears.txt')
    @word = word_picker
    @tries = 8
    @guessed = []
  end

  def word_picker
    loop do
      new_word = dictionary[Random.rand(dictionary.length)].chomp.downcase
      break new_word unless new_word.length < 5 || new_word.length > 12
    end
  end

  def letter_hider(string)
    result = string.split('').map do |letter|
      if guessed.include?(letter)
        letter
      else
        '-'
      end
    end
    result.join('')
  end

  def word_display(string = word)
    puts letter_hider(string)
  end

  def player_guess
    player.guess(self)
  end

  def guess_included?(guess)
    return true if guess.length == 1 && word.include?(guess)

    false
  end

  def tries_remaining
    puts "Tries remaining: #{tries}"
  end

  def victory?(guess)
    return true if guess == word

    true if letter_hider(word) == word
  end

  def victory
    puts "The secret word is #{word}! Congratulations #{player.name}, you win!"
  end

  def lose
    puts "You lose! Better luck next time! The secret word was #{word}"
  end

  def round(guess)
    return if victory?(guess)

    guessed.push guess

    self.tries -= 1 unless guess_included?(guess)

    tries_remaining
    word_display
  end

  def game
    word_display
    while tries.positive?
      guess = player_guess
      round(guess)

      break victory if victory?(guess)
    end
    lose unless victory?(guess)
  end

  public

  def play_hangman
    game
  end
end
