FROM ruby:3.3.5-alpine

WORKDIR /app

# 必要なパッケージをインストール
RUN apk add --no-cache \
    build-base \
    postgresql-dev \
    nodejs \
    yarn \
    git

# Gemfileをコピーしてbundle install
COPY Gemfile Gemfile.lock ./
RUN bundle install --without development test

# アプリケーションコードをコピー
COPY . .

# Node.jsの依存関係をインストール
RUN yarn install

# アセットのプリコンパイル（修正版）
RUN SECRET_KEY_BASE_DUMMY=1 RAILS_ENV=production bundle exec rails assets:precompile

# ポートを公開
EXPOSE $PORT

# アプリケーション起動
CMD bundle exec rails db:prepare && bundle exec rails server -h 0.0.0.0 -p $PORT