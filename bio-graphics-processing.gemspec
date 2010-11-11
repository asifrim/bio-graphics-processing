require 'rubygems'

spec = Gem::Specification.new do |s|
  s.name = 'bio-graphics-processing'
  s.version = "2.0"

  s.author = "Jan Aerts"
  s.email = "jan.aerts@gmail.com"
  s.homepage = "http://bio-graphics.rubyforge.org/"
  s.summary = "Library for visualizing genomic regions"

  s.platform = Gem::Platform::RUBY
  s.files = Dir.glob("{doc,lib,samples,test,images}/**/*").delete_if {|item| item.include?("SVN") || item.include?("rdoc")}

  # s.rdoc_options << '--exclude' << '.'
  s.has_rdoc = false

  s.add_dependency('bio', '>=1')
  s.add_dependency('ruby-processing', '>=1.0.9')
  s.require_path = 'lib'
  s.autorequire = 'bio-graphics-processing'
end

if $0 == __FILE__
  Gem::manage_gems
  Gem::Builder.new(spec).build
end
