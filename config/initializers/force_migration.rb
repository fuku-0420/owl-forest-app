if ENV['FORCE_MIGRATION'] == 'true' && Rails.env.production?
  Rails.application.configure do
    config.after_initialize do
      Rails.logger.info "🌟 FORCE_MIGRATION initializer loaded"

      # 少し待機してからマイグレーション実行
      Thread.new do
        sleep 2 # 2秒待機

        begin
          Rails.logger.info "🔄 Starting forced migration from initializer..."

          # データベース接続確認
          ActiveRecord::Base.connection.execute('SELECT 1')
          Rails.logger.info "✅ Database connection confirmed"

          # マイグレーション実行
          ActiveRecord::Base.connection.migration_context.migrate
          Rails.logger.info "✅ Forced migration completed!"

          # テーブル確認
          if ActiveRecord::Base.connection.table_exists?('owls')
            Rails.logger.info "✅ owls table exists!"
          else
            Rails.logger.error "❌ owls table still not found"
          end

        rescue => e
          Rails.logger.error "❌ Forced migration error: #{e.message}"
          Rails.logger.error e.backtrace.join("\n")
        end
      end
    end
  end
end