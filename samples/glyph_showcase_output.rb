require "rubygems"
require "bio-graphics-processing"
require 'ruby-processing'
require 'zlib'
panel = nil
Zlib::GzipReader.open('outputfile.gz') do |gz|
  panel =  Marshal.load(gz.read)
  gz.close
end

Processing::App
panel.draw

