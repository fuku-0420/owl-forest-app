threads_count = ENV.fetch("RAILS_MAX_THREADS", 3)
threads threads_count, threads_count

port ENV.fetch("PORT", 3000)

plugin :tmp_restart

# 開発環境ではシングルプロセス（安定）
if ENV.fetch("RAILS_ENV", "development") == "development"
  workers 0
else
  workers ENV.fetch("WEB_CONCURRENCY", 1)
end

preload_app!

on_worker_boot do
  ActiveRecord::Base.establish_connection if defined?(ActiveRecord)
end