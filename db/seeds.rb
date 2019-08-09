# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rails db:seed command (or created alongside the database with db:setup).
#
# Examples:
#
#   movies = Movie.create([{ name: 'Star Wars' }, { name: 'Lord of the Rings' }])
#   Character.create(name: 'Luke', movie: movies.first)

Photo.destroy_all

Dir.each_child(Rails.root.join('spec', 'support', 'assets', 'good')).each do |filename|
  photo = Photo.new
  photo.image.attach(io: File.open(Rails.root.join('spec', 'support', 'assets', 'good', filename)), filename: filename)
  photo.save
  photo.image.blob.analyze
  photo.pull_coords_from_image_metadata
  photo.save
end

puts "#{Photo.count} photos in the system..."
