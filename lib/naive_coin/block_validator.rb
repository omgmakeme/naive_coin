class BlockValidator
  def initialize(previous_block:, current_block:)
    @previous_block = previous_block
    @current_block = current_block
  end

  def valid?
    (valid_structure? &&
     valid_index? &&
     valid_previous_hash? &&
     valid_hash? &&
     valid_timestamp? &&
     valid_binary?)
  end

  private

  attr_reader :previous_block, :current_block

  def valid_structure?
    (current_block&.index.is_a?(Integer) &&
     current_block&.hash.is_a?(String) &&
     current_block&.previous_hash.is_a?(String) &&
     current_block&.timestamp.is_a?(Integer) &&
     current_block&.data.is_a?(String))
  end

  def valid_index?
    previous_block.index + 1 == current_block.index
  end

  def valid_previous_hash?
    previous_block.hash == current_block.previous_hash
  end

  def valid_hash?
    CalculateBlockHash.execute(block: current_block) == current_block.hash
  end

  def valid_timestamp?
    current_timestamp = Time.at(current_block.timestamp)
    previous_timestamp = Time.at(previous_block.timestamp)

    (current_timestamp < 1.minute.from_now &&
     previous_timestamp - 1.minute < current_timestamp)
  end

  def valid_binary?
    current_block.to_binary.match?(/^0{#{current_block.difficulty}}/)
  end
end
