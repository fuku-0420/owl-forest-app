if ENV['FORCE_MIGRATION'] == 'true' && ENV['RAILS_ENV'] == 'production'
  puts "🔄 Puma starting - Running Rails 8 migration..."

  begin
    # 現在のディレクトリを確認
    puts "📁 Current directory: #{Dir.pwd}"
    puts "📁 Rails root: #{defined?(Rails) ? Rails.root : 'Rails not loaded'}"

    # マイグレーション実行（複数の方法を試行）
    migration_success = false

    # Method 1: bundle exec rails db:migrate
    puts "🔧 Method 1: bundle exec rails db:migrate"
    if system("bundle exec rails db:migrate RAILS_ENV=production")
      puts "✅ Method 1 succeeded!"
      migration_success = true
    else
      puts "❌ Method 1 failed, trying Method 2..."

      # Method 2: bin/rails db:migrate
      puts "🔧 Method 2: bin/rails db:migrate"
      if system("bin/rails db:migrate RAILS_ENV=production")
        puts "✅ Method 2 succeeded!"
        migration_success = true
      else
        puts "❌ Method 2 failed, trying Method 3..."

        # Method 3: rake db:migrate
        puts "🔧 Method 3: rake db:migrate"
        if system("rake db:migrate RAILS_ENV=production")
          puts "✅ Method 3 succeeded!"
          migration_success = true
        end
      end
    end

    if migration_success
      puts "🎉 Migration completed successfully!"

      # テーブル存在確認
      if system("bundle exec rails runner 'puts ActiveRecord::Base.connection.table_exists?(\"owls\") ? \"owls table exists\" : \"owls table missing\"' RAILS_ENV=production")
        puts "📊 Table existence check completed"
      end
    else
      puts "❌ All migration methods failed"
    end

  rescue => e
    puts "❌ Migration error: #{e.message}"
  end
end