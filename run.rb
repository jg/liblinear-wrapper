#!/usr/bin/env ruby

$:.unshift(File.join(File.dirname(__FILE__), 'lib'))

require 'fileutils'
require 'models/dataset'
require 'models/model'
require 'utils/shell'


class Experiment
  DATASET_PATH = "datasets/"
  DATASETS = {
    :breast_cancer => Dataset.new(File.join(DATASET_PATH, 'breast-cancer'))
  }

  def evaluate
    DATASETS[:breast_cancer].on_test_train do |train, test|
      model = Model.train(train)
      model.predict(test)
    end
  end

  # @param [Dataset] dataset
  def run_batch(dataset)
    on_split_files(dataset_path, 6) do |paths|
      `liblinear/train datasets/#{dataset}`
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
