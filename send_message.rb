require 'twilio-ruby'
require 'dotenv/load'

account_sid, auth_token = ENV.values_at('TWILIO_ACCOUNT_SID', 'TWILIO_AUTH_TOKEN')
from_number, to_number = ENV.values_at('TWILIO_SENDING_PHONE_NUMBER', 'TWILIO_DEBUG_PHONE_NUMBER')

client = Twilio::REST::Client.new(account_sid, auth_token)

client.messages.create(
  from: from_number,
  to: to_number,
  body: "We're cookin' with gas now!"
)