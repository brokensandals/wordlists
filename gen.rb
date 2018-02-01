#!/usr/bin/env ruby

require 'erb'
require 'optparse'
require 'set'

options = {
  aggressive: false,
  include: [],
  exclude: [],
  max_length: 1000,
  min_length: 1,
  template: "#{File.join(File.dirname(__FILE__), 'templates', 'text.txt.erb')}"
}

OptionParser.new do |opts|
  opts.banner = 'Usage: gen.rb [options]'

  opts.on('-a', '--[no-]aggressive', 'Exclude words if an excluded word is a substring') do |aggressive|
    options[:aggressive] = aggressive
  end

  opts.on('-i' '--include FILE', 'Path to a file containing words to include') do |path|
    options[:include] << path
  end

  opts.on('-e', '--exclude FILE', 'Path to a file containing words to exclude') do |path|
    options[:exclude] << path
  end

  opts.on('-t', '--template FILE', 'Path to ERB file to use as template for output') do |path|
    options[:template] = path
  end

  opts.on('--min-length=MIN', 'Minimum number of characters for words to include') do |min|
    options[:min_length] = Integer(min)
  end

  opts.on('--max-length=MAX', 'Maximum number of characters for words to include') do |max|
    options[:max_length] = Integer(max)
  end
end.parse!

words = Set.new

options[:include].each do |path|
  File.read(path).each_line do |line|
    line.strip!
    next if line.empty?
    next if line.length < options[:min_length]
    next if line.length > options[:max_length]
    words.add(line)
  end
end

options[:exclude].each do |path|
  File.read(path).each_line do |line|
    line.strip!
    next if line.empty?
    if options[:aggressive]
      words.delete_if {|word| word.include?(line)}
    else
      words.delete(line)
    end
  end
end

print ERB.new(File.read(options[:template]), nil, '-').result(binding)
