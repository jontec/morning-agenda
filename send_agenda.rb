require 'twilio-ruby'
require 'dotenv/load'

require_relative 'airtable/company'

account_sid, auth_token = ENV.values_at('TWILIO_ACCOUNT_SID', 'TWILIO_AUTH_TOKEN')
from_number, to_number = ENV.values_at('TWILIO_SENDING_PHONE_NUMBER', 'TWILIO_DEBUG_PHONE_NUMBER')

client = Twilio::REST::Client.new(account_sid, auth_token)

agenda_items = Company.daily_tasks

text_message_lines = ["Good morning! Here's your tasks for the day:"]

agenda_items.each do |item|
  text_message_lines << "  - #{ item["Name"] }"
end

text_message_lines << "  - No tasks for you! :)" if text_message_lines.length == 1

client.messages.create(
  from: from_number,
  to: to_number,
  body: text_message_lines.join("\n")
)