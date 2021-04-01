# frozen_string_literal: false

require 'csv'
require 'google/apis/civicinfo_v2'
require 'erb'

def clean_zipcode(zipcode)
  zipcode.to_s.rjust(5, '0')[0..4]
end

def clean_phone_number(phone_number)
  phone_number = phone_number.to_s
  if phone_number.length < 10 || phone_number.length > 11 || phone_number.length == 11 && phone_number[0] != '1'
    'Bad Number' 
  elsif phone_number[0] == '1' && phone_number.length == 11
    phone_number[1..10]
  else
    phone_number
  end
end

def legislators_by_zipcode(zipcode)
  civic_info = Google::Apis::CivicinfoV2::CivicInfoService.new
  civic_info.key = 'AIzaSyClRzDqDh5MsXwnCWi0kOiiBivP6JsSyBw'

  begin
    legislators = civic_info.representative_info_by_address(
      address: zipcode,
      levels: 'country',
      roles: ['legislatorUpperBody', 'legislatorLowerBody']
    ).officials
  rescue
    'You can find your representatives by visiting www.commoncause.org/take-action/find-elected-officials'
  end
end

def save_thank_you_letter(id, form_letter)
  Dir.mkdir('output') unless Dir.exist?('output')
  filename = "output/thanks_#{id}.html"

  File.open(filename, 'w') do |file|
    file.puts form_letter
  end
end

File.exist?('event_attendees.csv')
puts 'EventManager Initialised'

contents = CSV.open(
  'event_attendees.csv',
  headers: true,
  header_converters: :symbol
)

template_letter = File.read('form_letter.erb')
erb_template = ERB.new template_letter

contents.each do |row|
  id = row[0]
  name = row[:first_name]
  phone_number = row[:homephone]

  phone_number = clean_phone_number(phone_number)

  zipcode = clean_zipcode(row[:zipcode])

  # legislators = legislators_by_zipcode(zipcode)

  puts "#{id} #{name} #{phone_number} #{zipcode}"

  # form_letter = erb_template.result(binding)

  # save_thank_you_letter(id, form_letter)
end
