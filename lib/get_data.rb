#!/usr/bin/env ruby

DATASETS = {
  'breast-cancer' =>
  'http://www.csie.ntu.edu.tw/~cjlin/libsvmtools/datasets/binary/breast-cancer_scale'
}

DIRPATH = "../datasets/"


def get_data
  DATASETS.each do |name, url|
    if !File.exist?(filename_path(name))
      puts "Downloading #{name}"
      wget(url, name)
    else
      puts "Skipping #{name}. Already downloaded"
    end
  end
end

def wget(url, name)
  system("/usr/bin/wget #{url} -O #{filename_path(name)}")
end

def filename_path(name)
  File.join(DIRPATH, name)
end

get_data
