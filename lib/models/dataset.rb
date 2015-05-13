require 'split_file'

class Dataset
  def initialize(path)
    @path = path
  end

  def name
    File.basename(@path)
  end


  # @return [Array<String>] array of examples
  def lines
    File.read(@path).split("\n")
  end

  def path
    @path
  end

  # @param [String] temporary directory path
  # @param [Integer] number of parts
  # @return [Array<Dataset>] datasets split evenly
  def split_n(tmpdir, number_of_parts)
    paths = SplitFile.new(tmpdir, @path).split_n(number_of_parts)
    paths.map { |p| Dataset.new(p) }
  end

  # @param [String] temporary directory path
  # @param [Float] split size ratio
  # @return [Array<Dataset>] datasets split in the given ratio
  def split2(tmpdir, ratio)
    paths = SplitFile.new(tmpdir, @path).split2(ratio)
    paths.map { |p| Dataset.new(p) }
  end

  # Ratio of the first path file size to the second one wil be 0.7
  #
  # @param [String] temporary directory path
  # @return [Array<Dataset>] train and test datasets respectively
  def train_test(tmpdir)
    split2(tmpdir, 0.7)
  end

  def one_vs_all(tmpdir)
    SplitFile.new(tmpdir, @path).split_into_classes.map do |h|
      {
        :class => h[:class],
        :dataset => Dataset.new(h[:path])
      }
    end
  end
end
