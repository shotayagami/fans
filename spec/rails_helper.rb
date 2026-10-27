require "spec_helper"
ENV["RAILS_ENV"] ||= "test"
ENV["STRIPE_WEBHOOK_SECRET"] ||= "whsec_test"
require_relative "../config/environment"
abort("The Rails environment is running in production mode!") if Rails.env.production?
require "rspec/rails"

Rails.root.glob("spec/support/**/*.rb").sort.each { |f| require f }

begin
  ActiveRecord::Migration.maintain_test_schema!
rescue ActiveRecord::PendingMigrationError => e
  abort e.to_s.strip
end

RSpec.configure do |config|
  config.use_transactional_fixtures = true
  config.infer_spec_type_from_file_location!
  config.filter_rails_from_backtrace!

  config.include FactoryBot::Syntax::Methods
  config.include Devise::Test::IntegrationHelpers, type: :request
  config.include ActiveJob::TestHelper
  config.include StripeHelpers

  # Every Stripe call in tests must be stubbed explicitly.
  config.before { Stripe.api_key = "sk_test_dummy" }
  config.around do |example|
    Bullet.start_request
    example.run
    Bullet.perform_out_of_channel_notifications if Bullet.notification?
    Bullet.end_request
  end
end
