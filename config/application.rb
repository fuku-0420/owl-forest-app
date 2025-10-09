require_relative "boot"

require "rails/all"

Bundler.require(*Rails.groups)

module FukurouApp
  class Application < Rails::Application
    config.load_defaults 8.0

    config.encoding = "utf-8"

    config.autoload_lib(ignore: %w[assets tasks])

    # 🎯 Rails 8 Propshaft アセット設定を追加
    config.assets.paths << Rails.root.join("app", "assets", "builds")
    config.assets.paths << Rails.root.join("app", "assets", "images")

    # 開発環境でのアセット配信を確実にする
    config.assets.compile = true if Rails.env.development?

    # 🌟 Rails 8対応の安全なマイグレーション実行
    if ENV['FORCE_MIGRATION'] == 'true' && Rails.env.production?
      config.after_initialize do
        Rails.application.executor.wrap do
          begin
            Rails.logger.info "🔄 FORCE_MIGRATION enabled - Starting migration..."

            # データベース接続確認
            ActiveRecord::Base.connection.execute('SELECT 1')
            Rails.logger.info "✅ Database connection established"

            # Rails 8対応の安全なマイグレーション実行
            if defined?(ActiveRecord::Tasks::DatabaseTasks)
              ActiveRecord::Tasks::DatabaseTasks.migrate
              Rails.logger.info "✅ Migration completed successfully!"
            else
              # フォールバック: Rakeタスクを使用
              Rails.application.load_tasks
              Rake::Task['db:migrate'].invoke
              Rails.logger.info "✅ Migration completed via Rake task!"
            end

            # テーブル存在確認
            if ActiveRecord::Base.connection.table_exists?('owls')
              Rails.logger.info "✅ owls table created successfully!"
            else
              Rails.logger.warn "⚠️ owls table not found after migration"
            end

          rescue => e
            Rails.logger.error "❌ Migration failed: #{e.message}"
            Rails.logger.error "Error class: #{e.class}"
            Rails.logger.error e.backtrace.first(10).join("\n")
          end
        end
      end
    end
  end
end
