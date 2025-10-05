if ENV['FORCE_MIGRATION'] == 'true' && Rails.env.production?
  Rails.application.configure do
    config.after_initialize do
      Thread.new do
        sleep 2  # 起動待ち時間を短縮

        begin
          Rails.logger.info "🔄 Starting lightweight migration..."

          # 最もシンプルなマイグレーション実行
          system("rails db:migrate RAILS_ENV=production")

          Rails.logger.info "✅ Migration completed"

        rescue => e
          Rails.logger.error "❌ Migration failed: #{e.message}"
        end
      end
    end
  end
end