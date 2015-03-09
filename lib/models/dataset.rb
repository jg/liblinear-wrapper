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

  def on_split_n(number_of_parts)
    paths = SplitFile.new(@path).split_n(number_of_parts)
    yield(paths.map { |p| Dataset.new(p) })
  ensure
    paths.each { |path| FileUtils.rm(path) }
  end

  def on_split2(ratio)
    paths = SplitFile.new(@path).split2(ratio)
    yield(paths.map { |p| Dataset.new(p) })
  ensure
    paths.each { |path| FileUtils.rm(path) }
  end

  def on_test_train
    on_split2(0.7) do |paths|
      yield(paths[0], paths[1])
    end
  end
end
