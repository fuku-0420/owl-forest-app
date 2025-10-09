require "active_support/core_ext/integer/time"

Rails.application.configure do
  config.enable_reloading = false
  config.eager_load = true
  config.consider_all_requests_local = false
  config.action_controller.perform_caching = true
  config.public_file_server.headers = { "cache-control" => "public, max-age=#{1.year.to_i}" }

  # 🔥 ここから追加設定 🔥
  # 静的ファイル配信を有効化
  config.public_file_server.enabled = true
  config.serve_static_assets = true

  # アセット設定
  config.assets.compile = false
  config.assets.precompile += %w[
    app.css
    owls.css
    application.js
    *.js
    *.png *.jpg *.jpeg *.gif *.svg
  ]
    # 🔥 キャッシュ設定の最適化 🔥
  config.public_file_server.headers = { 
    "cache-control" => "public, max-age=#{1.year.to_i}",
    "expires" => 1.year.from_now.to_formatted_s(:rfc822)
  }

  config.active_storage.service = :local
  config.assume_ssl = true
  config.force_ssl = true
  config.log_tags = [ :request_id ]
  config.logger   = ActiveSupport::TaggedLogging.logger(STDOUT)
  config.log_level = ENV.fetch("RAILS_LOG_LEVEL", "info")
  config.silence_healthcheck_path = "/up"
  config.active_support.report_deprecations = false
  config.cache_store = :solid_cache_store
  config.active_job.queue_adapter = :solid_queue
  config.solid_queue.connects_to = { database: { writing: :queue } }
  config.action_mailer.default_url_options = { host: "example.com" }
  config.i18n.fallbacks = true
  config.active_record.dump_schema_after_migration = false
  config.active_record.attributes_for_inspect = [ :id ]
end