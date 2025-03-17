# This file should ensure the existence of records required to run the application in every environment (production,
# development, test). The code here should be idempotent so that it can be executed at any point in every environment.
# The data can then be loaded with the bin/rails db:seed command (or created alongside the database with db:setup).
#
# Example:
#
#   ["Action", "Comedy", "Drama", "Horror"].each do |genre_name|
#     MovieGenre.find_or_create_by!(name: genre_name)
#   end
credentials = Rails.application.credentials

company_attributes = credentials.company.with_indifferent_access
company = Company.find_or_create_by(company_attributes)
puts 'Company created'

user_attributes = credentials[:user].with_indifferent_access.merge(company_id: company.id)
store_attributes = credentials[:store].with_indifferent_access.merge(company_id: company.id)

User.find_or_create_by(email: user_attributes[:email]) do |user|
  user.assign_attributes(user_attributes)
end
puts 'User created'

Store.find_or_create_by(store_attributes)
puts 'Store created'
