# add all files in /lib to path
$:.unshift File.join(File.dirname(__FILE__), "lib")
require 'rmagick-blend'

###

desc "show rake tasks"
task :default do
  puts `rake -T`
end


namespace :build do
  desc "prepare for rspec"
  task :prepare_rspec do
    Utils::create_dir_if_needed(File.join('spec', 'assets', 'source'))
    Utils::create_dir_if_needed(File.join('spec', 'assets', 'destination'))
  end
end

namespace :batch do
    desc "make blends"
    task :run do
        RMagickBlend::start
    end
end

namespace :get_material do
    desc "get faves"
    task :get_flickr_faves do
        require 'ruby-flickr'
        ruby_flickr = RubyFlickr.new
        ruby_flickr.get_creative_common_faves
    end
end
