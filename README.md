# morning-agenda

## About

I built this app to learn more about the Twilio and Airtable APIs. This app is intended to send a daily notification that helps you start your day with a summary of information sourced from Airtable.

## Status

1. Send a text message with Twilio
2. Integrate with Airtable
3. Host on Heroku & configure automation

## Setup

### Configure Twilio

If you're new to Twilio, you can configure a trial account to get started quickly: https://www.twilio.com/try-twilio

Many of the following instructions follow the guidance for the [Ruby Quickstart](https://www.twilio.com/docs/sms/quickstart/ruby#install-ruby-and-the-twilio-helper-library)

You'll want to make sure you perform the following steps before proceeding:
 * Configure a phone number (to send text messages)
 * Validate the phone number (if you're on a trial)

### Send a Text Message

#### Get the Twilio gem

First, you'll need the Twilio gem. You can either install it directly:

```ruby
gem install twilio-ruby
```

Or create a Gemfile, add the gem, and run bundle install:

```
bundle init
```

Add the gem to your Gemfile:

```
bundle add twilio-ruby
```

We know that we'll be deploying to Heroku, so it's not a bad idea to get our Gemfile started now.

#### Storing Your Secrets

Again, since we'll be deploying to Heroku, let's setup our Twilio configurations in `.env` and load them using the `dotenv` gem so that we can minimize future rework when we deploy.

Add the gem to your `Gemfile` (or install it via `gem install dotenv`) and run `bundle install`:

```
bundle add dotenv
```

Create `.env` in your directory and add in all of your custom details:

```
TWILIO_ACCOUNT_SID=xxxxxxxxxxx
TWILIO_AUTH_TOKEN=xxxxxxxx
TWILIO_SENDING_PHONE_NUMBER="+1XXXXXXXXXX"
TWILIO_DEBUG_PHONE_NUMBER="+1XXXXXXXXXX"
```

Don't forget to exempt this file from version control to keep your secrets safe. Add it to your `.gitignore`:

`echo ".env" >> .gitignore`

And now, when we create our script, we'll use `require 'dotenv/load'` to automatically load this basic environment file.

#### Make it Sing

Let's build a simple script to send our first message:

Let's get the Twilio client library and load the environment variables:
```ruby
require 'twilio-ruby'
require 'dotenv/load'
```

Load and collect our environment variables so that they're easy to work with:

```ruby
account_sid, auth_token = ENV.values_at('TWILIO_ACCOUNT_SID', 'TWILIO_AUTH_TOKEN')
from_number, to_number = ENV.values_at('TWILIO_SENDING_PHONE_NUMBER', 'TWILIO_DEBUG_PHONE_NUMBER')
```

And finally, let's initialize the client and send our text message:

```ruby
client = Twilio::REST::Client.new(account_sid, auth_token)

client.messages.create(
  from: from_number,
  to: to_number,
  body: "We're cookin' with gas now!"
)
```

And you should receive a text message almost immediately!