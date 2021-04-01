# frozen_string_literal: false

require 'csv'

File.exist?('event_attendees.csv')

contents = CSV.open(
  'event_attendees.csv',
  headers: true,
  header_converters: :symbol
)
contents.each do |row|
  name = row[:first_name]
  zipcode = row[:zipcode]
  puts "#{name} #{zipcode}"
end
