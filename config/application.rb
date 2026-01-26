require_relative "boot"

require "rails/all"

Bundler.require(*Rails.groups)

module FukurouApp
  class Application < Rails::Application
    config.load_defaults 8.0

    # i18n
    config.i18n.default_locale = :ja
    config.i18n.available_locales = [ :ja, :en ]
    config.i18n.fallbacks = { ja: :en } # 翻訳が無いキーは英語へフォールバック

    config.encoding = "utf-8"

    config.autoload_lib(ignore: %w[assets tasks])

    # 🎯 Rails 8 Propshaft アセット設定
    config.assets.paths << Rails.root.join("app", "assets", "builds")
    config.assets.paths << Rails.root.join("app", "assets", "images")
    config.assets.paths << Rails.root.join("app", "assets", "audios")

    # 開発環境でのアセット配信
    config.assets.compile = true if Rails.env.development?

    # 🌟 Rails 8対応の安全なマイグレーション実行
    if ENV["FORCE_MIGRATION"] == "true" && Rails.env.production?
      config.after_initialize do
        Rails.application.executor.wrap do
          begin
            Rails.logger.info "🔄 FORCE_MIGRATION enabled - Starting migration..."

            ActiveRecord::Base.connection.execute("SELECT 1")
            Rails.logger.info "✅ Database connection established"

            if defined?(ActiveRecord::Tasks::DatabaseTasks)
              ActiveRecord::Tasks::DatabaseTasks.migrate
              Rails.logger.info "✅ Migration completed successfully!"
            else
              Rails.application.load_tasks
              Rake::Task["db:migrate"].invoke
              Rails.logger.info "✅ Migration completed via Rake task!"
            end

            if ActiveRecord::Base.connection.table_exists?("owls")
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
