# config/environments/production.rb
require "active_support/core_ext/integer/time"

Rails.application.configure do
  config.enable_reloading = false
  config.eager_load = true
  config.consider_all_requests_local = false
  config.action_controller.perform_caching = true

  # =========================================================
  # 静的ファイル（Propshaft / Rails 8）
  # =========================================================
  # Render 等の本番環境で assets が 404 にならないように明示的に有効化
  config.public_file_server.enabled = true
  config.serve_static_files = true

  # Propshaft 環境でも必要な静的ファイルが配信されるように precompile 対象を明示
  config.assets.compile = true
  config.assets.digest = true
  config.assets.debug = false

  config.assets.precompile += %w[
    builds/app.css
    builds/owls.css
    application.js
    *.js
    *.css
    *.png *.jpg *.jpeg *.gif *.svg
  ]

  # 静的ファイルのキャッシュ（長期キャッシュ）
  config.public_file_server.headers = {
    "cache-control" => "public, max-age=#{1.year.to_i}",
    "expires" => 1.year.from_now.to_formatted_s(:rfc822)
  }

  # =========================================================
  # ActiveStorage（本番）
  # =========================================================
  # 再デプロイ後も画像を保持したいので、S3互換ストレージ（:amazon）を使用する
  # ※ storage.yml の amazon 設定 + Render 側の環境変数が必須
  config.active_storage.service = :amazon

  # =========================================================
  # SSL / ログ
  # =========================================================
  config.assume_ssl = true
  config.force_ssl = true

  config.log_tags = [:request_id]
  config.logger = ActiveSupport::TaggedLogging.logger(STDOUT)
  config.log_level = ENV.fetch("RAILS_LOG_LEVEL", "info")

  config.silence_healthcheck_path = "/up"
  config.active_support.report_deprecations = false

  # =========================================================
  # キャッシュ / ジョブ（Solid系）
  # =========================================================
  config.cache_store = :solid_cache_store

  # SolidQueue 構成だと、本番で DB（queue）未設定時に ActiveStorage 関連のジョブ enqueue が失敗し
  # プロフィール更新等で 500 になることがあるため async にする
  config.active_job.queue_adapter = :async

  # =========================================================
  # メール / i18n / DB
  # =========================================================
  config.action_mailer.default_url_options = { host: "example.com" }

  config.i18n.fallbacks = true
  config.active_record.dump_schema_after_migration = false
  config.active_record.attributes_for_inspect = [:id]
end
