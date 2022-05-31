require_relative 'player'
require 'yaml'
require 'pry-byebug'

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

  def start_menu
    puts 'Let\'s play Hangman! Type !load or !start to load or start a game. Use !save to save and quit once started.'

    begin
      response = player_guess
      raise StandardError unless ['!start', '!load'].include?(response)
    rescue StandardError
      puts 'Invalid input, please try again'
      retry
    end

    game if response == '!start'
    load_game.game if response == '!load'
  end

  def save_game
    save = File.open('saves/save.csv', 'w')
    save.puts YAML.dump(self)
    save.close
    exit
  end

  def no_saves
    puts 'No saves exist, returning to start menu'
    start_menu
  end

  def load_game
    return no_saves unless File.exist?('saves/save.csv')

    save = File.open('saves/save.csv', 'r')
    save_file = save.read
    save.close

    YAML.safe_load(save_file, [self.class, player.class])
  end

  def word_picker
    loop do
      new_word = dictionary[Random.rand(dictionary.length)].chomp.downcase
      break new_word unless new_word.length < 5 || new_word.length > 12
    end
  end

  def hidden_word(string = word)
    result = string.split('').map do |letter|
      if guessed.include?(letter)
        letter
      else
        '-'
      end
    end
    result.join('')
  end

  def player_guess
    player.guess(self)
  end

  def incorrect_letters
    guessed.each_with_object([]) { |guess, array| array << guess if word.include?(guess) == false && guess.length == 1 }
  end

  def guess_included?(guess)
    return true if guess.length == 1 && word.include?(guess)

    false
  end

  def victory?(guess)
    return true if guess == word

    true if hidden_word(word) == word
  end

  def victory
    puts "The secret word is #{word}! Congratulations #{player.name}, you win!"
  end

  def lose
    puts "You lose! Better luck next time! The secret word was #{word}"
  end

  def round(guess)
    return if victory?(guess)

    save_game if guess == '!save'

    guessed.push guess

    self.tries -= 1 unless guess_included?(guess)

    puts "Tries remaining: #{tries}"
    puts hidden_word
    puts "Incorrect letters guessed: #{incorrect_letters}"
  end

  protected

  def game
    puts hidden_word
    while tries.positive?
      guess = player_guess
      round(guess)

      break victory if victory?(guess)
    end
    lose unless victory?(guess)
  end

  public

  def play_hangman
    start_menu
  end
end
