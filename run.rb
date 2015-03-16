#!/usr/bin/env ruby

$:.unshift(File.join(File.dirname(__FILE__), 'lib'))

require 'fileutils'
require 'models/dataset'
require 'models/model'
require 'utils/shell'
require 'tmpdir'


class Experiment
  DATASET_PATH = "datasets/"
  DATASETS = {
    :breast_cancer => Dataset.new(File.join(DATASET_PATH, 'breast-cancer'))
  }

  def evaluate
    Dir.mktmpdir do |tmpdir|
      train, test = DATASETS[:breast_cancer].train_test(tmpdir)
      model = Model.train(tmpdir, train)
      model.predict(tmpdir, test)
    end
  end

  # @param [Dataset] dataset
  def run_batch(dataset)
    on_split_files(dataset_path, 6) do |paths|
      `liblinear/train datasets/#{dataset}`
    end
  end

  def train_one_vs_all
    Dir.mktmpdir do |tmpdir|
      train, test = DATASETS[:breast_cancer].train_test(tmpdir)

      train.one_vs_all(tmpdir).each do |data|
        puts "Training: #{data[:class]}"
        model = Model.train(tmpdir, data[:dataset])
        p = model.predict(tmpdir, test, data[:class])
        puts p
        puts "-------------------"
        puts "| #{p.tp} #{p.fn} |"
        puts "| #{p.fp} #{p.tn} |"
        puts "-------------------"
        puts "precision: #{p.precision}, recall #{p.recall}"
      end
    end
  end


  # @params [Model] model
  def predict(model, training_set_file, options)
  end

  def datasets
    @datasets ||= dataset_paths.map { |path| Dataset.new(path) }
  end

  def dataset_paths
    @dataset_paths ||= Dir.glob(DATASET_PATH)
  end

  # Divides file into non-overlapping parts, writes those into current directory
  # with .part.n suffix
  def burst_file(name, parts)
    Shell.new.run("/usr/bin/split -n #{parts} --numeric-suffixes=1 #{name}" \
           "#{name}.part.")

  end

end
