require 'airrecord'

Airrecord.api_key = ENV['AIRTABLE_API_KEY']

class Company < Airrecord::Table
  self.base_key = ENV['AIRTABLE_BASE_ID']
  self.table_name = "Companies"

  def self.daily_tasks
    all(filter: '{Next Touch} <= TODAY()')
  end
end