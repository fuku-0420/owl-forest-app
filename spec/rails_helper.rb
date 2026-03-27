require 'spec_helper'
ENV['RAILS_ENV'] ||= 'test'
require_relative '../config/environment'

abort("The Rails environment is running in production mode!") if Rails.env.production?

require 'rspec/rails'

# support配下のファイル読み込み
Dir[Rails.root.join('spec/support/**/*.rb')].sort.each { |f| require f }

begin
  ActiveRecord::Migration.maintain_test_schema!
rescue ActiveRecord::PendingMigrationError => e
  abort e.to_s.strip
end

RSpec.configure do |config|
  # FactoryBotを使いやすくする
  config.include FactoryBot::Syntax::Methods

  # fixture使うならそのまま（使わないなら消してもOK）
  config.fixture_paths = [
    Rails.root.join('spec/fixtures')
  ]

  # トランザクション内でテスト実行
  config.use_transactional_fixtures = true

  # specの種類を自動判別（これ地味に重要）
  config.infer_spec_type_from_file_location!

  # Railsのノイズ削減
  config.filter_rails_from_backtrace!
end
