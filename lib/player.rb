# Holds player data and methods
class Player
  attr_reader :name

  private

  def initialize(name:)
    @name = name
  end

  def player_input
    gets.chomp.downcase
  end

  def player_guess(guessed)
    input = player_input
    raise RuntimeError if guessed.include?(input)

    input
  rescue RuntimeError
    puts 'Already guessed, please try again!'
    retry
  end

  public

  def guess(game)
    player_guess(game.guessed)
  end
end
