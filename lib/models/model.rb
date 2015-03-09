require 'utils/shell'
require 'models/predictions'

class Model
  def initialize(path)
    @path = path
  end

  # Train a new Model
  #
  # @param [String] temporary directory path
  # @param [Dataset]
  # @return [Model] model
  def self.train(tmpdir, train, options = {})
    basename = File.basename(train.path).split('.')[0] + '.model'
    model_path = File.join(tmpdir, basename)
    Shell.new.run("liblinear/train #{train.path} #{model_path}")

    Model.new(model_path)
  end

  # @param [Dataset]
  def predict(tmpdir, test)
    predictions_path = File.join(tmpdir, 'predictions')
    Shell.new.run("liblinear/predict #{test.path} #{@path} #{predictions_path}")
    Predictions.new(predictions_path)
  end
end
