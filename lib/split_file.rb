class SplitFile
  # @param [String] temporary directory path
  # @param [String] path to the file that we need to split
  def initialize(tmpdir, path)
    @tmpdir = tmpdir
    @path = path
  end

  # Splits text file into two chunks according to the given size ratio between
  # the first file and the second one. Parts will have a .part.<n> suffix
  #
  # @params [Float] ratio
  # @returns [Array<String>] array of paths
  def split2(ratio)
    lines = File.read(@path).split("\n")
    split_point = (lines.size*ratio).to_i
    file1 = lines[0..split_point].join("\n")
    file2 = lines[split_point+1..lines.size-1].join("\n")


    basename = File.basename(@path)
    file1name = basename + ".part.1"
    file2name = basename + ".part.2"
    path1 = File.join(@tmpdir, file1name)
    path2 = File.join(@tmpdir, file2name)
    File.open(path1, 'w') { |f| f.write(file1) }
    File.open(path2, 'w') { |f| f.write(file2) }

    [path1, path2]
  end

  # Splits text file into n parts
  #
  # @params [Integer] number of parts
  # @return [Array<String>] array of paths of the split files
  def split_n(n)
    lines = File.read(@path).split("\n")

    ranges = generate_ranges(lines.size, n)
    parts = ranges.map do |range|
      lines[range[0]..range[1]]
    end

    basename = File.basename(@path)
    filenames = (1..n).to_a.map { |k| basename + ".part.#{k}" }
    paths = filenames.map { |name| File.join(@tmpdir, name) }
    
    filenames.each_with_index do |filename, i|
      File.open(paths[i], 'w') do |f|
        f.write(parts[i].join("\n"))
      end
    end

    paths
  end

  def generate_ranges(size, n)
    per_part = (size/n).to_i
    remaining = size % n

    ranges =
      (1..n).to_a.map { |k| [0, k*per_part] }


    ranges.drop(1).each_with_index do |p, i|
      p[0] = ranges[i][1]+1
    end

    if remaining != 0
      ranges[ranges.size] = [ranges.last[0], ranges.last[1]+remaining]
    end

    ranges
  end

  # Splits libsvm data file into two files per class. One containing
  # the positive examples of class, the other one the negative ones.
  #
  # @return [Hash]
  # Example:
  # {
  #   :class => 1
  #   :positives => PATH
  #   :negatives => PATH
  # }
  def split_into_classes
    lines = File.read(@path).split("\n")

    class_of_line = -> (line) { Integer(line.split(" ")[0]) }

    classes = lines.map do |line|
      class_of_line.call(line)
    end.uniq

    out = []
    
    classes.each do |class_number|
      positives, negatives = lines.partition do |line|
        class_of_line.call(line) == class_number
      end

      replace_class_number = -> (line, replacement) {
        replacement + " " + line.split(" ").drop(1).join(" ")
      }

      basename = File.basename(@path).split('.')[0]
      path = File.join(@tmpdir, "#{basename}.class.#{class_number}")

      File.open(path, 'w') do |f|
        # replace "positive" instance class numbers with +1
        patched_positives = positives.map do |line|
          replace_class_number.call(line, "+1")
        end

        # replace "negative" instance class numbers with -1
        patched_negatives = negatives.map do |line|
          replace_class_number.call(line, "-1")
        end

        all = patched_positives + patched_negatives
        f.write(all.shuffle.join("\n"))
      end

      out << {
        :class => class_number,
        :path => path
      }

      return out if classes.size == 2
    end

    out
  end
end
