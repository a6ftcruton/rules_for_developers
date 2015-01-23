class GuessChecker
  attr_reader :guess, :sequence, :printer

  def initialize(guess, sequence)
    @guess    = guess
    @sequence = sequence
    @printer = MessagePrinter.new
  end

  def matches_found
    ( 0..(sequence.length - 1) ).select {|index| guess[index] == sequence[index]}.length
  end

  def correct_color
    matches      = 0
    dup_sequence = sequence.dup
    guess.each do |color|
      if dup_sequence.include? color
        matches += 1
        color_index = dup_sequence.index(color)
        dup_sequence.delete_at(color_index)
      end
    end
    matches
  end

  def feedback
    printer.guess_feedback(guess, matches_found, correct_color)
  end
end
