require_relative 'player'
require_relative 'save_system'

# Holds script for the game hangman
class Hangman
  attr_reader :guessed

  private

  attr_accessor :word, :tries
  attr_writer :guessed
  attr_reader :player, :dictionary, :serialize

  def initialize(player:, serialize:)
    @player = player
    @dictionary = File.readlines('google-10000-english-no-swears.txt')
    @word = word_picker
    @tries = 8
    @guessed = []
    @serialize = serialize
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

    return game if response == '!start'

    load_game.game
  end

  def save_game
    serialize.save_menu(command: '!save', game: self)
  end

  def load_game
    serialize.save_menu(command: '!load', game: self, classes_to_load: [self.class, player.class, serialize.class])
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
    true if guess.length == 1 && word.include?(guess)
  end

  def victory?(guess)
    true if guess == word || hidden_word(word) == word
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

Hangman.new(player: Player.new(name: 'Player'), serialize: SaveSystem.new).play_hangman
