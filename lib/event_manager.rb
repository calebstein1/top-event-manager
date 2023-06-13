require 'csv'
require 'erb'
require 'phone'
require 'google/apis/civicinfo_v2'
puts 'Event Manager Initialized!'

def validate_zipcode(zipcode)
  zipcode.to_s.rjust(5, '0')[0..4]
end

def validate_phone_number(phone)
  pn = Phoner::Phone.parse(phone, country_code: '1')
  pn.format("%a%n")
rescue
  "Invalid phone number"
end 

def find_legislators(zipcode)
  civic_info = Google::Apis::CivicinfoV2::CivicInfoService.new
  civic_info.key = 'AIzaSyClRzDqDh5MsXwnCWi0kOiiBivP6JsSyBw'

  begin
    civic_info.representative_info_by_address(
      address: zipcode,
      levels: 'country',
      roles: ['legislatorUpperBody', 'legislatorLowerBody']
    ).officials
  rescue
    'You can find your representatives by visiting www.commoncause.org/take-action/find-elected-officials'
  end
end

def generate_letter(id, form_letter)
  Dir.mkdir('output') unless Dir.exist?('output')
  filename = "output/thanks_#{id}.html"
  File.open(filename, 'w') { |file| file.puts form_letter }
end

contents = CSV.open(
  'event_attendees.csv',
  headers: true,
  header_converters: :symbol
)
erb_template = ERB.new File.read('form_letter.erb')

contents.each do |row|
  id = row[0]
  name = row[:first_name]
  zipcode = validate_zipcode(row[:zipcode])
  #legislators = find_legislators(zipcode)
  #form_letter = erb_template.result(binding)

  #generate_letter(id, form_letter)

  puts row[:homephone]
  puts validate_phone_number(row[:homephone])
end
