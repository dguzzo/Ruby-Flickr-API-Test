# make sure the ImageMagick library itself is installed on the system, then:
# gem install rmagick

require 'RMagick'

image_name = "Bookshelves"
test_image = Magick::Image.read("./images/#{image_name}.jpg").first
cols, rows = test_image.columns, test_image.rows

puts "processing file #{image_name}..."
test_image[:caption] = "Hi!"
test_image = test_image.polaroid { self.gravity = Magick::CenterGravity }

test_image.change_geometry!("#{cols}x#{rows}") do |ncols, nrows, img|
    img.resize!(ncols, nrows)
end

puts "writing processed file..."
test_image.write("./images/#{image_name}_polaroid.png")
puts "done!"