require_relative "boot"

require "rails/all"

Bundler.require(*Rails.groups)

module FukurouApp
  class Application < Rails::Application
    config.load_defaults 8.0

    config.encoding = "utf-8"

    config.autoload_lib(ignore: %w[assets tasks])

    # 🌟 強制マイグレーション実行機能を追加
    if ENV['FORCE_MIGRATION'] == 'true' && Rails.env.production?
      config.after_initialize do
        begin
          Rails.logger.info "🔄 FORCE_MIGRATION enabled - Starting migration..."

          # データベース接続確認
          ActiveRecord::Base.connection.execute('SELECT 1')
          Rails.logger.info "✅ Database connection established"

          # マイグレーション実行
          ActiveRecord::Base.connection.migration_context.migrate
          Rails.logger.info "✅ Migration completed successfully!"

          # テーブル存在確認
          if ActiveRecord::Base.connection.table_exists?('owls')
            Rails.logger.info "✅ owls table created successfully!"
          else
            Rails.logger.warn "⚠️ owls table not found after migration"
          end

        rescue => e
          Rails.logger.error "❌ Migration failed: #{e.message}"
          Rails.logger.error e.backtrace.join("\n")
        end
      end
    end
  end
end