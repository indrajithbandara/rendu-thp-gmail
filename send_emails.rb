require 'rubygems'
require 'nokogiri' 
require 'open-uri'
require "google_drive"
require 'gmail'


# Get the worksheet
def get_worksheet(worksheet_key)
  # Grab the auth from config.json
  session = GoogleDrive::Session.from_config("config.json")
  # Get the spreadsheet by key
  session.spreadsheet_by_key(worksheet_key).worksheets[0]
end

# Parse the spreadsheat
def go_through_all_the_lines(worksheet_key)
  # Declare empty array for swaping
  data = []
  # Call the get_worksheet function to get the worksheet
  worksheet = get_worksheet(worksheet_key)
  # Iterate each row
  worksheet.rows.each do |row|
    # Put the email in the data array
    data << row[1].gsub(/[[:space:]]/, '')
  end 
    # return the data as an array
    return data
end

# Get the html data for the email
def get_email_html(file_path)
  # Create empty string 
  data = ''
  # Open the file with read permission
  f = File.open(file_path, "r") 
  # Iterate each line and add it to the data
  f.each_line do |line|
    data += line
  end
   # Return the data as a string
  return data
end

# Get image for email
def get_email_image(image_path)
  # Return the path as a string
  return image_path
end

# Save output to text file
def save_to_file(emails)
  # Open the file with writing permission
  File.open("email_sent_list.txt","w") do |file|
  # Iterate the array
    emails.each do |email|
      # Write in the file to save output
      file.write("Email successfully sent to #{email}\n")
    end
  end  
end

# Send email 6 parameters worksheet_key, html_path, image_path are hard coded
def send_gmail_to_listing(username, password, subject_text, worksheet_key, html_path, image_path)
  # Connect to gmail and puts
  # username and password are parameters you will input as argument on command line
  gmail = Gmail.connect(username, password)
  puts "Gmail login"

  # Call the go_through_all_the_lines function wich returns all the emails in an array
  email_listing = go_through_all_the_lines(worksheet_key)

  # Iterate through all the emails
  email_listing.each do |email|
    # For each email send mail to email
    gmail.deliver do
      to email
      # subject_text variable is a parameter you will input as argument on command line
      subject subject_text
        # Send the content in the email as html
        html_part do
          content_type 'text/html; charset=UTF-8'
          # Call the get_email_html function to get the body content
          body get_email_html(html_path)
        end
      # Call the get_email_image function to add an image to the email
      add_file get_email_image(image_path)
    end
      # Puts a message on console when the email is successfully sent
      puts "Email successfully sent to #{email}"
  end
  # Call the save_to_file function to save the output in a text file
  save_to_file(email_listing)
  # Log out of gmail and puts
  gmail.logout
  puts "Gmail logout script finished"

end

# Get user input for the username argument
puts "Please enter your Google email"
username = gets.chomp.to_s

# Get user input for the password argument
puts "Please enter your password"
password = gets.chomp.to_s

# Get user input for the email subject argument
puts "Please enter the email subject"
subject = gets.chomp.to_s

# Call the send_email_to_listing function with all arguments to excute the script
send_gmail_to_listing(username, password, subject, "1uGaDLBLGFZxqx72bUalxkfnTR7B0AD2SWTWAaDPkLKg", "email_template.html", "thp.png")





