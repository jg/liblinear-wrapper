# Predictions class for one vs all classification
class Predictions
  # @param [Dataset] testing dataset
  # @param [String] predictions file path
  def initialize(train, path, positive_class)
    predictions = File.read(path).split("\n").map(&:to_i)
    actual =
      begin
        classes =
          File.read('datasets/breast-cancer').split("\n").map do |l|
            l.split(" ")[0].to_i
          end
        classes.map { |c| c == positive_class ? 1 : 0 }
      end
    @zipped = predictions.zip(actual)
  end

  def to_s
    @zipped.map do |prediction, actual|
      "#{prediction} (#{actual})"
    end.join("\n")
  end

  def tp
    count = 0
    @zipped.each do |prediction, actual|
      if prediction == 1 && prediction == actual
        count = count + 1
      end
    end
    count
  end

  def fp
    count = 0
    @zipped.each do |prediction, actual|
      if prediction == 1 && prediction != actual
        count = count + 1
      end
    end
    count
  end

  def fn
    count = 0
    @zipped.each do |prediction, actual|
      if prediction == 0 && prediction != actual
        count = count + 1
      end
    end
    count
  end

  def tn
    count = 0
    @zipped.each do |prediction, actual|
      if prediction == 0 && prediction == actual
        count = count + 1
      end
    end
    count
  end

  def precision
    tp.to_f / (tp + fp)
  end

  def recall
    tp.to_f / (tp + fn)
  end
end
