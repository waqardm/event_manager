def clean_date(time)
  hour = DateTime.strptime(time, '%m/%d/%y %H:%M')
  hour = hour.hour
end