require 'utils/shell'
class Model
  def initialize(path)
    @path = path
  end

  # @param [Dataset]
  # @return [Model] model
  def self.train(dataset, options = {})
    Shell.new.run("liblinear/train #{dataset.path}")

    basename = File.basename(dataset.path).split('.')[0] + '.model'
    Model.new(basename)
  end

  def predict(dataset)
    Shell.new.run("liblinear/predict #{dataset.path} #{@path} prediction")
  end
end
