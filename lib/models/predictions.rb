# Predictions class for one vs all classification
class Predictions
  # @param [Dataset] testing dataset
  # @param [String] predictions file path
  def initialize(test, predictions_path, positive_class)
    predictions = File.read(predictions_path).split("\n").map(&:to_i)
    actual = test.lines.map do |line|
      line.split(" ")[0].to_i
    end
    @zipped = predictions.zip(actual)
  end

  def to_s
    @zipped.map do |prediction, actual|
      fmt = "%2d"
      p = fmt % prediction
      a = fmt % actual
      "#{p} (#{a})"
    end.join("\n")
  end

  def add_plus(prediction)
    prediction > 0 ? "+#{prediction}" : prediction
  end

  def confusion_matrix
    fmt = "%4d"
    a = fmt % tp
    b = fmt % fn
    c = fmt % fp
    d = fmt % tn
    ["------------",
    "| #{a} #{b} |",
    "| #{c} #{d} |",
    "-------------"].join("\n")
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
