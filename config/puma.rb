threads_count = ENV.fetch("RAILS_MAX_THREADS", 3)
threads threads_count, threads_count

# Specifies the `port` that Puma will listen on to receive requests; default is 3000.
port ENV.fetch("PORT", 3000)

# Allow puma to be restarted by `bin/rails restart` command.
plugin :tmp_restart

# Run the Solid Queue supervisor inside of Puma for single-server deployments
plugin :solid_queue if ENV["SOLID_QUEUE_IN_PUMA"]

# Specify the PID file. Defaults to tmp/pids/server.pid in development.
# In other environments, only set the PID file if requested.
pidfile ENV["PIDFILE"] if ENV["PIDFILE"]

# メモリ使用量を抑制するため、ワーカー数を制限
workers ENV.fetch("WEB_CONCURRENCY", 1)  # 無料プラン用に1に設定

# プリロードでメモリ効率を向上
preload_app!

# ワーカー起動時の設定
on_worker_boot do
  ActiveRecord::Base.establish_connection if defined?(ActiveRecord)
end