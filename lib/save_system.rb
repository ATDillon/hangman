require 'yaml'

# Handles serialization and deserialization of game files
class SaveSystem
  private

  attr_accessor :save_file
  attr_reader :save_slots

  def initialize(save_slots: %w[save_one.csv save_two.csv save_three.csv])
    @save_slots = save_slots
    @save_file = nil
  end

  def save_or_load(command, game, classes_to_load)
    return save_game(game) if command == '!save'

    return no_saves(game) if no_saves?

    load_game(classes_to_load)
  end

  def return_to_game(game)
    game.play_game
  end

  def save_game(game)
    save_slot_selection
    save = File.open("saves/#{save_file}", 'w')
    save.puts YAML.dump(game)
    save.close
    exit
  end

  def no_saves?
    true unless save_slots.any? { |file| File.exist?("saves/#{file}")}
  end

  def no_saves(game)
    puts 'Error: No save files exist to load, returning to start'
    return_to_game(game)
  end

  def empty_slot(classes_to_load)
    puts 'This slot is empty, please pick another and try again'
    load_game(classes_to_load)
  end

  def slots_status
    files = save_slots.each_with_object([]).with_index do |(file, array), index|
      next array << "Save #{index + 1}" if File.exist?("saves/#{file}")

      array << 'Empty'
    end

    <<-STATUS
      Slot One: #{files[0]}
      Slot Two: #{files[1]}
      Slot Three: #{files[2]}
    STATUS
  end

  def load_game(classes_to_load)
    save_slot_selection
    empty_slot(classes_to_load) unless File.exist?("saves/#{save_file}")

    save = File.open("saves/#{save_file}", 'r')
    load_file = save.read
    save.close

    YAML.safe_load(load_file, classes_to_load)
  end

  def save_slot_selection
    puts 'Which save slot would you like to use? Please enter 1-3'
    puts slots_status
    begin
      response = Integer(gets.chomp)
      raise ArgumentError if response.negative? || response > 3
    rescue ArgumentError
      puts 'Invalid input, please enter 1-3'
      retry
    end
    self.save_file = save_slots[response - 1]
  end

  public

  def save_menu(command:, game:, classes_to_load: nil)
    save_or_load(command, game, classes_to_load)
  end
end
