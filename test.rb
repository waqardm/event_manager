# frozen_string_literal: false

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

phone_number = 12345678900
puts clean_phone_number(phone_number)


# If the phone number is less than 10 digits, assume that it is a bad number
# If the phone number is 10 digits, assume that it is good
  # If the phone number is 11 digits and the first number is 1, trim the 1 and use the first 10 digits
  # If the phone number is 11 digits and the first number is not 1, then it is a bad number
# If the phone number is more than 11 digits, assume that it is a bad number