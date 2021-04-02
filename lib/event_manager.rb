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

def get_hour(time)
  DateTime.strptime(time, '%m/%d/%y %H:%M').hour
end

def weekday_finder(time)
  date = DateTime.strptime(time, '%m/%d/%y %H:%M').cwday
  case date
  when 1 
    'Monday'
  when  2
    'Tuesday'
  when 3
    'Wednesday'
  when 4
    'Thursday'
  when 5
    'Friday'
  when 6
    'Saturday'
  when 7
    'Sunday'
  end
end

def most_active_hour(arr, hour_or_day)
  counts = arr.each_with_object(Hash.new(0)) do |count, new_hash|
   new_hash[count] += 1
  end
  if hour_or_day == "hour"
    return counts.each { |k, v| puts "Most active hour is: #{k}, where #{v} people registered" if v == counts.values.max }
  elsif hour_or_day == "day"
    return counts.each { |k, v| puts "Most active day is: #{k}, where #{v} people registered" if v == counts.values.max }
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

hours = []
weekdays = []

contents.each do |row|
  id = row[0]
  name = row[:first_name]
  phone_number = row[:homephone]

  reg_date_hour_finder = get_hour(row[:regdate])
  weekday_finder = weekday_finder(row[:regdate])

  hours << reg_date_hour_finder
  weekdays << weekday_finder
  
  phone_number = clean_phone_number(phone_number)

  zipcode = clean_zipcode(row[:zipcode])

  # legislators = legislators_by_zipcode(zipcode)

  # form_letter = erb_template.result(binding)

  # save_thank_you_letter(id, form_letter)
end

most_active_hour(hours, 'hour')
most_active_hour(weekdays, 'day')