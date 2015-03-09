require 'split_file'

class Dataset
  def initialize(path)
    @path = path
  end

  def name
    File.basename(@path)
  end

  def path
    @path
  end

  def split_n(tmpdir, number_of_parts)
    paths = SplitFile.new(tmpdir, @path).split_n(number_of_parts)
    paths.map { |p| Dataset.new(p) }
  end

  # @param [String] temporary directory path
  # @param [Float] split size ratio
  def split2(tmpdir, ratio)
    paths = SplitFile.new(tmpdir, @path).split2(ratio)
    paths.map { |p| Dataset.new(p) }
  end

  # Ratio of the first path file size to the second one wil be 0.7
  #
  # @param [String] temporary directory path
  # @yield [String, String] two parts of the split
  def train_test(tmpdir)
    split2(tmpdir, 0.7)
  end
end
