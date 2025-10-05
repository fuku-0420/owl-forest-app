FROM ruby:3.2.3

WORKDIR /app

# システムの依存関係をインストール
RUN apt-get update -qq && apt-get install -y \
    nodejs \
    postgresql-client \
    && rm -rf /var/lib/apt/lists/*

# Gemfileをコピーして依存関係をインストール
COPY Gemfile* ./
RUN bundle install

# アプリケーションコードをコピー
COPY . .

# アセットのプリコンパイル
RUN RAILS_ENV=production bundle exec rails assets:precompile

# ポートを公開
EXPOSE $PORT

# DB準備とサーバー起動
CMD bundle exec rails db:prepare && bundle exec rails server -h 0.0.0.0 -p $PORT