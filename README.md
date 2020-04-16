# morning-agenda

## About

I built this app to learn more about the Twilio and Airtable APIs. This app is intended to send a daily notification that helps you start your day with a summary of information sourced from Airtable.

## Status

1. ~~Send a text message with Twilio~~
2. ~~Integrate with Airtable~~
3. ~~Host on Heroku & configure automation~~
4. Explore fancier Twilio & Airtable capabilities

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

### Integrate with Airtable

The data source powering our app--to give our text messages some meaning and usefulness without a human on the others side--is a Table within a Base in Airtable.

For this use case, we'll say that we'll send an agenda of Companies to contact (for example, if you're a member of a Sales team) each morning. This list will be relevant to us based on the activities we'll perform throughout the day (which might be stored in another table called "Activities", but we'll keep it simple for now).

Using a date field "Next Touch" in this Table, we'll filter the records just to those that I should have followed up with in the days prior and those I need to contact today. Then, before I even arrive at the office, I'll have a nice list of relationships I need to work on today.

#### Configure the Client Library

To keep things simple, we'll use a community-developed client lirbary called [`airrecord`](https://github.com/sirupsen/airrecord) which has an ActiveRecord-like interface to the Airtable API. This will allow us to use user-friendly abstractions to obtain records and represent their relationships programmatically within our app.

Add the gem to our Gemfile and install it:
```
bundle add airrecord
```

If you haven't already, you'll need to generate an account-level API key and obtain the ID of your Airtable Base.

We'll add these two our `.env` alongside our existing Twilio secrets:
```
AIRTABLE_API_KEY="xxxxxxxxxxx"
AIRTABLE_BASE_ID="xxxxxxxxxxx"
```

#### Create a Model for the Connection

Since `airrecord` has an ActiveRecord-like interface, we'll need to create a model to represent the Table in Airtable that stores our records.

Let's reference our API key and Base ID inside the file, and include the name of the table exactly as it appears in Airtable to complete our link.

Out of the gate, we'll include `Company.daily_tasks` as a macro to help us quickly access only those records relevant to our daily agenda. We'll use a bit of short hand to call the `Company.all` method, which selects all records from the table, and then filter on a native Airtable condition that looks for records whose "Next Touch" field is less than or equal to today's date (tasks that are due today or earlier).

As a note, I started a directory called `airtable/` to store my Airtable "models" in one place. These could grow over time as we added more and more tables to our integration.

```ruby
require 'airrecord'

Airrecord.api_key = ENV['AIRTABLE_API_KEY']

class Company < Airrecord::Table
  self.base_key = ENV['AIRTABLE_BASE_ID']
  self.table_name = "Companies"
	
  def self.daily_tasks
    all(filter: '{Next Touch} <= TODAY()')
  end
end
```

#### Send a Text with Airtable Data

I've created a copy of our initial script called `send_agenda.rb` to ensure that there's an example available in the repo at each relevant step. You could keep building off the original instead! Instructions will reference the new file from this point forward, though.

Now that we have a model, we can simply reference it in our script to retrieve the data we need:

```ruby
require_relative 'airtable/company'
```

To find the records, we simply call our macro, iterate over the records retrieved, then use those records to build and send our message.

We can reference any field for a given record as using the column's name in Airtable as the (string) key (e.g. `record["name"]` for "Name")

```ruby
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
```

We've now sent an Airtable-powered text message!

### Deploy to Heroku

Building all this plumbing means nothing if we don't have some automation, to wake us up in the morning, right?

We want to send a text message with our selected set of tasks each morning around 8:00AM. We'll do this by deploying our application to Heroku and then using the free Heroku scheduler to send a message.

#### Create a New App

Setup a new app on Heroku (or a similar, per-compute provider) and link your app's repo to your local git repository.

```
heroku login

heroku git:remote -a app-name
```

Once your code is all set and committed locally, push it out to Heroku to deploy:
```
git push heroku master
```

#### Set Environment Variables

The environment variables that live in `.env` are not version-controlled and therefore not accessible inside your app. Manually add these as "Config Vars" for your app in its Settings, 1:1 to each environment variable declared. Once your app is running, these will be set as environment variables and your app should work just as if `.env` had been available.

#### Check & Schedule

Once the Config Vars have been defined, check your work by spinning up a one-off dyno to run your code:

```
heroku run "ruby send_agenda.rb"
```

If there are no errors, we're ready to automate it! Add the [Heroku Scheduler add-on](https://elements.heroku.com/addons/scheduler), which will allow us to specify when and how often our app should run automatically.

Once the add-on has been configured, visit the Scheduler to add a job that publishes our agenda daily at 3:00pm UTC (8:00AM PDT), executing the following command:

```
ruby send_agenda.rb
```