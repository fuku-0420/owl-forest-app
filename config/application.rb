require_relative "boot"
require "rails/all"

Bundler.require(*Rails.groups)

module FukurouApp
  class Application < Rails::Application
    config.load_defaults 8.0
    config.encoding = "utf-8"
    config.autoload_lib(ignore: %w[assets tasks])

    # 🌟 Rails 8.0対応：migration_contextを使わない方法
    if ENV['FORCE_MIGRATION'] == 'true' && Rails.env.production?
      config.after_initialize do
        begin
          Rails.logger.info "🔄 FORCE_MIGRATION enabled - Starting migration..."

          # データベース接続確認
          ActiveRecord::Base.connection.execute('SELECT 1')
          Rails.logger.info "✅ Database connection established"

          # Rails 8.0対応：systemコマンドで確実実行
          Rails.logger.info "🔄 Executing migration via system command..."
          migration_result = system("RAILS_ENV=production bin/rails db:migrate 2>&1")
          
          if migration_result
            Rails.logger.info "✅ Migration completed successfully!"
          else
            Rails.logger.warn "⚠️ Migration command returned error, but continuing..."
          end

          # テーブル存在確認
          if ActiveRecord::Base.connection.table_exists?('owls')
            Rails.logger.info "✅ owls table created successfully!"
          else
            Rails.logger.warn "⚠️ owls table not found after migration"
          end

        rescue => e
          Rails.logger.error "❌ Migration failed: #{e.message}"
          # アプリは継続起動（重要）
        end
      end
    end
  end
end