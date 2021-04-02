# frozen_string_literal: false

require 'csv'
require 'google/apis/civicinfo_v2'
require 'erb'
require 'date'

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

def clean_date(time)
  DateTime.strptime(time, '%m/%d/%y %H:%M').hour
end

def most_active_hour(arr)
  hour_counts = arr.each_with_object(Hash.new(0)) do |hour, new_hash|
   new_hash[hour] += 1
  end
  return hour_counts.each { |k, v| puts "Most active hour is: #{k}, where #{v} people registered" if v == hour_counts.values.max }
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

hours = []

contents.each do |row|
  id = row[0]
  name = row[:first_name]
  phone_number = row[:homephone]

  reg_date_hour_finder = clean_date(row[:regdate])

  hours << reg_date_hour_finder
  
  phone_number = clean_phone_number(phone_number)

  zipcode = clean_zipcode(row[:zipcode])

  # legislators = legislators_by_zipcode(zipcode)

  # form_letter = erb_template.result(binding)

  # save_thank_you_letter(id, form_letter)
end

most_active_hour(hours)