class Game
  attr_reader :guess_count,
              :cli,
              :printer,
              :guess,
              :sequence,
              :game,
              :player,
              :elapsed_time

  def initialize
    @guess_count      = 0
    @cli              = CLI.new
    @printer          = MessagePrinter.new
    @guess            = []
    @sequence         = []
    @game             = self
  end

  def show_instructions
    @show_instructions = GameInstructions.load_instructions
    printer.command_options
  end

  def elapsed_time
    @elapsed_time = (@time_finish - @time_start).to_i
  end

  def initiate_game(difficulty)
    @difficulty = difficulty
    @sequence   = SequenceGenerator.generate(difficulty)
    @time_start = Time.new
    get_correct_instructions(difficulty)
    run
  end

  def get_correct_instructions(difficulty)
    printer.instructions(difficulty)
  end

  def run
    #printer.show_sequence_for_dev_purposes(sequence)
    prompt_for_guess
    case
    when quit?
      printer.quit
    when invalid_input?
      input_error_message
    when correct_guess?
      @guess_count += 1
      @time_finish = Time.new
      printer.win_message(guess_count, elapsed_time)
      get_user_name
      HiScores.write_hi_scores(@game)
      get_input_after_win
      cli.run
    else
      @guess_count += 1
      printer.incorrect_guess(@guess_count)
      guess_checker = GuessChecker.new(guess, sequence)
      guess_checker.feedback
      run
    end
  end

  def get_user_name
    printer.prompt_for_user_name
    @player = gets.chomp.upcase
    printer.thank_player(player)
  end

  def get_input_after_win
    printer.options_after_win
    input = gets.downcase.chomp
    case input
    when 'q', 'quit' then printer.quit
    when 'p', 'play' then initiate_game
    when 's', 'scores' then
      printer.hi_scores_banner
      HiScores.print_hi_scores
    else
      printer.command_options
    end
  end


  private


  def prompt_for_guess
    printer.request_guess
    @guess = gets.downcase.chomp.split(//)
  end

  def quit?
    guess == ["q"]
  end

  def invalid_input?
    guess.length != @difficulty ||
    case @difficulty
    when 'b', 4
      !guess.all? {|i| i.match(/r|g|b|y/)}
    when 'i', 6
      !guess.all? {|i| i.match(/r|g|b|y|c/)}
    else
      !guess.all? {|i| i.match(/r|g|b|y|c|m/)}
    end
  end

  def input_error_message
    case
    when quit?
      printer.quit
    when !guess.all? {|i| i.match(/r|g|b|y/)}
      printer.input_error("characters other than r, g, b, or y")
      run
    when guess.length < 4
      printer.input_error("too few characters")
      run
    when guess.length > 4
      printer.input_error("too many characters")
      run
    else
      printer.input_error("an unknown error.")
      run
    end
  end

  def correct_guess?
    guess == sequence
  end
end
