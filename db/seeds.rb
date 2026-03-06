# This file should ensure the existence of records required to run the application in every environment (production,
# development, test). The code here should be idempotent so that it can be executed at any point in every environment.
# The data can then be loaded with the bin/rails db:seed command (or created alongside the database with db:setup).
#
# Example:
#
#   ["Action", "Comedy", "Drama", "Horror"].each do |genre_name|
#     MovieGenre.find_or_create_by!(name: genre_name)
#   end

# Create sample users for development (password: "password")
[
  { name: "John", email: "john@example.com" },
  { name: "anbu", email: "anbu@example.com" },
  { name: "Michael Victor", email: "michael.victor@example.com" }
].each do |attrs|
  User.find_or_create_by!(email: attrs[:email]) do |u|
    u.name = attrs[:name]
    u.password = "password"
    u.password_confirmation = "password"
  end
end
