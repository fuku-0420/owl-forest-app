# frozen_string_literal: true

puts "🌱 Seeding start..."

ActiveRecord::Base.transaction do
  # =========================================================
  # Owl（フクちゃん）
  # =========================================================
  Owl.find_or_initialize_by(name: "フクちゃん").tap do |owl|
    owl.species     = "学習サポートフクロウ"
    owl.age         = 28
    owl.habitat     = "知識の森"
    owl.description = "学習者に寄り添い、つまずきをやさしく案内してくれるフクロウ"
    owl.save!
  end

  # =========================================================
  # Category（黒板）
  # =========================================================
  categories = {
    "学習"               => "アルゴリズム/ネットワーク/DBなど学習内容",
    "Rails"              => "Railsで詰まりやすい点",
    "SQL"                => "DB/SQLのつまずき",
    "設計"               => "責務分割・設計の悩み",
    "開発"               => "開発作業・運用で使う知識",
    "エラー"             => "よくあるエラーと対処",
    "モチベ"             => "不安・やる気・継続",
    "みんなのお悩み解決" => "学習中のリアルな悩みを共有・解決する場所"
  }

  categories.each do |name, desc|
    Category.find_or_initialize_by(name: name).tap do |c|
      c.description = desc
      c.save!
    end
  end

  # =========================================================
  # Category 参照
  # =========================================================
  study        = Category.find_by!(name: "学習")
  rails        = Category.find_by!(name: "Rails")
  sql          = Category.find_by!(name: "SQL")
  design       = Category.find_by!(name: "設計")
  dev          = Category.find_by!(name: "開発")
  error        = Category.find_by!(name: "エラー")
  motiva       = Category.find_by!(name: "モチベ")
  trouble      = Category.find_by!(name: "みんなのお悩み解決")

  # =========================================================
  # Advice 定義（seed管理：seed_key を固定で持つ）
  # =========================================================
  advices = [

    # -------------------------
    # 開発
    # -------------------------
    {
      seed_key: "dev.git_checkout_switch",
      category: dev,
      title: "ブランチ切替コマンド",
      body: <<~TEXT
        結論：ブランチ操作なら、やっていることはほぼ同じ。
        ただし「分かりやすさ」が違う。

        ▼ ブランチ作成して切り替え
        新しい書き方（ブランチ専用で分かりやすい）
          git switch -c feature/xxx

        昔からある書き方（何でもできる分、混乱しやすい）
          git checkout -b feature/xxx

        ▼ ブランチ切り替え
          git switch main
          git checkout main

        ▼ なぜ switch を推すの？
        checkout は「ブランチ切り替え」と「ファイル復元」も兼ねるため、
        初学者が混乱しやすい。
        ブランチ作業は switch に寄せると理解が速い。
      TEXT
    },
    {
      seed_key: "dev.pr_check_min",
      category: dev,
      title: "提出前の確認",
      body: <<~TEXT
        PRを出す前に、まずこれだけやればOK。

        ▼ 差分確認
          git status
          git diff

        ▼ テスト
          bin/rails test

        ▼ 静的解析（入れてるなら）
          bundle exec rubocop

        ▼ 可能ならローカル起動して目視
          bin/rails s

        目的は「落ちるものを先に潰す」。
        小さく確認してからPRを出すと、レビューが通りやすい。
      TEXT
    },
    {
      seed_key: "dev.rubocop_a_A",
      category: dev,
      title: "自動整形",
      body: <<~TEXT
        RuboCopの自動修正は便利だけど、使い分けが大事。

        ▼ 安全な自動修正のみ（基本これ）
          bundle exec rubocop -a

        ▼ より強い自動修正（挙動が変わる修正も含む）
          bundle exec rubocop -A

        -A は強力だけど、意図しない変更が混ざることがある。
        使った後は必ず diff を見て確認しよう。

          git diff
      TEXT
    },
    {
      seed_key: "dev.migrate_vs_seed",
      category: dev,
      title: "migrate と seed",
      body: <<~TEXT
        migrate と seed は役割が違う。

        ▼ migrate：DBの構造を変える（テーブル/カラムの追加など）
          bin/rails db:migrate

        ▼ seed：初期データやサンプルデータを投入する
          bin/rails db:seed

        基本は「構造を変えたら migrate → 必要なら seed」。
      TEXT
    },
    {
      seed_key: "dev.binrails_vs_bundleexec",
      category: dev,
      title: "Railsコマンド実行方法",
      body: <<~TEXT
        結論：普段は bin/rails でOK。

        ▼ よく使う
          bin/rails s
          bin/rails c
          bin/rails db:migrate
          bin/rails db:seed

        ▼ bundle exec rails を使う場面（考え方）
        Gemfileの環境を確実に使いたいとき。
        ただし Rails の binstub（bin/rails）があるなら、
        だいたい bin/rails が面倒を見てくれる。

        迷ったら：
        「bin/rails を基本」「困ったら bundle exec」を覚えればOK。
      TEXT
    },

    # -------------------------
    # Rails
    # -------------------------
    {
      seed_key: "rails.gemfile",
      category: rails,
      title: "Gemfile（ライブラリ管理）",
      body: <<~TEXT
        Gemfileは「使う部品の一覧」。

        gemを追加 → bundle install → 使えるようになる。

        group :development do
          gem "rubocop"
        end

        開発用と本番用を分けられる。

        Gemfile = 使う機能の設計書。
      TEXT
    },
    {
      seed_key: "rails.controller",
      category: rails,
      title: "コントローラの役割",
      body: <<~TEXT
        コントローラは「受け取って、決めて、渡す」。

        ・paramsを受け取る
        ・モデルを呼ぶ
        ・表示を決める（render / redirect）

        迷ったら：
        「どの画面に出すか決める」→ コントローラ
      TEXT
    },
    {
      seed_key: "rails.view",
      category: rails,
      title: "ビューの役割",
      body: <<~TEXT
        ビューは「見た目担当」。

        ・表示する
        ・並べる
        ・リンクやフォームを書く

        計算やDB操作はしない。
        画面表示だけに集中させる。
      TEXT
    },
    {
      seed_key: "rails.migration",
      category: rails,
      title: "マイグレーション（DB変更）",
      body: <<~TEXT
        マイグレーションはDB構造の変更履歴。

        bin/rails db:migrate

        テーブル追加・カラム追加を管理する。

        構造変更 → migrate
        データ投入 → seed
      TEXT
    },
    {
      seed_key: "rails.n_plus_one",
      category: rails,
      title: "N+1（遅くなる原因）",
      body: <<~TEXT
        ループ内で毎回DB検索すると、
        クエリが爆発的に増える。

        投稿100件 → 101回クエリ。

        解決：includes

        「まとめて取る」が基本。
      TEXT
    },

    # -------------------------
    # SQL
    # -------------------------
    {
      seed_key: "sql.what_is_sql",
      category: sql,
      title: "SQLとは",
      body: <<~TEXT
        SQLは、リレーショナルデータベースを操作する言語。

        特徴は「宣言的」であること。
        手順を書くのではなく、
        「何をしたいか」だけを書く。

        例：
        SELECT name FROM users WHERE age > 20;

        これは
        「20歳以上の名前を取得したい」と宣言しているだけ。
        どうやって探すかはDBMS（データベースマネジメントシステム）が決める。

        手続き型言語とは考え方が違う。
      TEXT
    },
    {
      seed_key: "sql.execution_order",
      category: sql,
      title: "実行順序",
      body: <<~TEXT
        SQLは、書いた順に実行されない。

        SELECT文の論理的な実行順序：

        FROM
        JOIN
        ON
        WHERE
        GROUP BY
        HAVING
        SELECT
        ORDER BY

        先にデータを集め、
        そのあとで表示する列を決めている。

        書く順と処理順は違う。
        ここがSQL理解の分岐点。
      TEXT
    },
    {
      seed_key: "sql.where_clause",
      category: sql,
      title: "WHERE句",
      body: <<~TEXT
        WHERE句は、行を絞り込むための条件を指定するもの。
        リレーショナルDBでは「1行＝1件のデータ」。

        だから、どのデータを対象にするかは
        “行単位”で決める。

        もしWHEREがなければ、全件が対象になる。
        UPDATEやDELETEでは重大事故になる。

        列を選ぶのはSELECT。
        列を更新するのはSET。
        WHEREは「どの行を触るか」を決めている。
      TEXT
    },
    {
      seed_key: "sql.group_by",
      category: sql,
      title: "GROUP BY句",
      body: <<~TEXT
        GROUP BYは、行をグループ化する。

        同じ値を持つ行をまとめて、
        集計関数（COUNT, SUMなど）と一緒に使う。

        例：
        SELECT department, COUNT(*)
        FROM employees
        GROUP BY department;

        注意：
        GROUP BYで指定していない列は、
        SELECTにそのまま書けない。

        「グループ単位」で考える。
      TEXT
    },
    {
      seed_key: "sql.having",
      category: sql,
      title: "HAVING句",
      body: <<~TEXT
        HAVINGは、グループ化後の条件。

        WHEREは行に対する条件。
        HAVINGはグループに対する条件。

        例：
        SELECT department, COUNT(*)
        FROM employees
        GROUP BY department
        HAVING COUNT(*) > 5;

        WHERE → 行フィルター
        HAVING → グループフィルター
      TEXT
    },
    {
      seed_key: "sql.left_join",
      category: sql,
      title: "LEFT JOIN",
      body: <<~TEXT
        LEFT JOINは、左側のテーブルをすべて残す結合。

        右側に一致するデータがなければ、
        NULLになる。

        例：
        SELECT *
        FROM customers
        LEFT JOIN orders
          ON customers.id = orders.customer_id;

        LEFTは「左を全部残す」と覚える。
      TEXT
    },

    # -------------------------
    # 設計
    # -------------------------
    {
      seed_key: "design.mvp",
      category: design,
      title: "MVP",
      body: <<~TEXT
        MVPは「仮説を検証するための最小構成」。

        完成品を目指すのではなく、
        「本当に価値があるか？」を確かめるために作る。

        例：タスク管理アプリ

        ❌ 通知・検索・タグ・共有まで全部作る
        ⭕ タスク作成と完了だけ作る

        まず検証するのは
        「ユーザーはタスクを登録するか？」

        ▼ 考えること
        ・何を検証したい？
        ・それに必要な最小機能は？
        ・成功の基準は？

        MVPは完成形ではない。
        学ぶための実験装置。
      TEXT
    },
    {
      seed_key: "design.flow",
      category: design,
      title: "設計の進め方",
      body: <<~TEXT
        設計は順番がすべて。

        ① MVPを決める
           → 何を検証するのかを明確にする

        ② 画面遷移図を描く
           → ユーザーの動線を整理する

        ③ 保存する情報を洗い出す
           → 本当に必要なデータを見極める

        ④ ER図を作る
           → データ構造を整理する

        ⑤ バリデーションを決める
           → データのルールを定める

        ⑥ Issueに分解する
           → 実装できるサイズに落とす

        ⑦ READMEで言語化する
           → 設計を他人に説明できる形にする

        設計ができる = 迷いが減る。
      TEXT
    },
    {
      seed_key: "design.er_diagram",
      category: design,
      title: "ER図",
      body: <<~TEXT
        ER図は「設計図」ではなく、
        要件をデータ構造に翻訳した結果。

        ▼ 手順
        1) 誰が何をするか書き出す
        2) 保存したい名詞だけ抜き出す
        3) 1テーブル1責務で整理する
        4) 関係性を決める（1対多・多対多）
        5) 必須カラムだけ決める
        6) 最後に図にする

        描けないときは前の段階に戻る。
        ER図が描ける = 実装の8割が終わっている。
      TEXT
    },
    {
      seed_key: "design.normalization",
      category: design,
      title: "正規化",
      body: <<~TEXT
        正規化は「データの矛盾を防ぐ整理」。

        正規化していないと：
        ・同じ情報を何度も持つ
        ・一部だけ更新されて不整合が起きる
        ・削除で関係ないデータまで消える

        ▼ 第1正規形
        1セル1値（複数値を入れない）

        ▼ 第2正規形
        主キーの一部だけに依存する情報を分ける

        ▼ 第3正規形
        他のカラムに依存するカラムを分ける

        意識するのは
        「同じ意味のデータを何度も持っていないか？」
      TEXT
    },
    {
      seed_key: "design.screen_transition",
      category: design,
      title: "画面遷移図",
      body: <<~TEXT
        画面遷移図は「ユーザーの動線の設計」。

        なぜ必要？
        ・導線の抜け漏れを防ぐ
        ・必要なデータが見えてくる
        ・認証設計の漏れを防ぐ

        ▼ 最小の作り方
        ・主要画面を箱で並べる
        ・リンクやボタンで矢印を引く
        ・分岐が破綻してないか確認

        実装前に描くと、迷いが減る。
      TEXT
    },
    {
      seed_key: "design.validation",
      category: design,
      title: "バリデーション",
      body: <<~TEXT
        バリデーションは「壊れたデータを入れない防御」。

        決めること：
        ・必須か？
        ・一意か？
        ・長さ制限はあるか？

        モデルで守る。
        DBで最終防衛する。

        設計時に決めると、
        実装がブレない。
      TEXT
    },
    {
      seed_key: "design.issue",
      category: design,
      title: "Issue",
      body: <<~TEXT
        Issueは「設計を実装単位に分解するツール」。

        大きすぎるIssueは、
        設計が曖昧なサイン。

        目安：
        ・1Issue = 1目的
        ・1日以内で終わるサイズ
        ・完了条件が明確

        小さく切れる人は、
        設計ができている人。
      TEXT
    },
    {
      seed_key: "design.readme",
      category: design,
      title: "README",
      body: <<~TEXT
        READMEは「設計の言語化」。

        書けないときは、
        設計が整理できていない。

        最低限：
        ・目的
        ・想定ユーザー
        ・主な機能
        ・ER図
        ・技術スタック

        READMEが書ける = 設計が整理できている。
      TEXT
    },

    # -------------------------
    # 学習
    # -------------------------
    {
      seed_key: "study.algorithm",
      category: study,
      title: "アルゴリズム",
      body: <<~TEXT
        アルゴリズムとは
        処理を「そのまま実行できる形」まで具体化した手順のこと。

        やりたいことやイメージが浮かぶだけでは、
        まだアルゴリズムとしては足りない。

        最低限、次の3つが決まっている必要がある。
        ・順番（何を先にやるか）
        ・条件（いつ分かれるか）
        ・終了（どこで終わるか）

        たとえば「カレーを作りたい」は目的。
        「野菜を切って煮る」はイメージ。

        でも、順番・時間・完成条件が決まっていないと
        実行できるレシピにならない。

        イメージを、実行できる手順に落とす。
        それがアルゴリズム。
      TEXT
    },
    {
      seed_key: "study.bubble_sort",
      category: study,
      title: "バブルソート",
      body: <<~TEXT
        バブルソートは、データを並び替えるアルゴリズムの一つ。

        やっていることはシンプルで、
        隣同士の要素を比べて、順番が逆なら入れ替える。
        これを何回かくり返す。

        重要なのは「1回のループで何が起きるか」。
        1周すると、一番大きい値が右端へ送られる。

        右端が確定したら、次はその手前まで。
        確定済みの範囲が少しずつ広がっていく。

        特徴まとめ：
        ・隣同士を比べる
        ・比べるたびに交換する
        ・大きい値を後ろに送る
      TEXT
    },
    {
      seed_key: "study.selection_sort",
      category: study,
      title: "選択ソート",
      body: <<~TEXT
        選択ソートは、
        残っている中から一番小さい値を選んで、前に置く並び替え。

        やっていること：
        ・左から順に、位置を1つずつ確定させる
        ・右側を最後まで調べる（最小値の位置を探す）
        ・最後に1回だけ交換する
        ・途中では交換しない

        特徴まとめ：
        ・最後まで探す
        ・交換は1回だけ
        ・小さい値を前に置く

        覚え方：
        「探し切ってから、入れ替える」
      TEXT
    },
    {
      seed_key: "study.flowchart_reading",
      category: study,
      title: "フローチャート",
      body: <<~TEXT
        フローチャートは、アルゴリズムを図で表したもの。
        中身ではなく「ループや分岐の構造」を見える化している。

        読むポイントは、記号や数字を細かく追うよりも、
        まず“流れ”を見ること。

        ・どこから始まっているか
        ・どこをくり返しているか
        ・どこで終わるか

        ソート系でよく出る見方：
        ・外側ループ：位置（確定範囲）を進める
        ・内側ループ：比較・探索をする

        「今、確定している場所はどこ？」
        「今、探している範囲はどこ？」
        これが言葉で追えると、フローチャートが急に読めるようになる。
      TEXT
    },

    # -------------------------
    # エラー
    # -------------------------
    {
      seed_key: "error.http_status",
      category: error,
      title: "HTTPステータスコード",
      body: <<~TEXT
        HTTPステータスコードは、
        リクエストの結果を3桁の数字で表すもの。

        先頭の数字で意味が分かれる。

        100番台：
        処理は続いているという合図。
        裏側のやり取りで使われることが多く、
        普段目にすることはほとんどない。

        200番台：
        正常に処理が完了した状態。
        200が返れば、基本的に成功。

        300番台：
        別の場所へ移動している状態。
        ブラウザが自動でリダイレクトすることが多い。

        400番台：
        リクエスト側に問題がある。
        URLの間違いや認証ミスなど。

        500番台：
        サーバー内部で問題が発生している。
        プログラムのエラーや過負荷など。

        エラーが出たら、
        まず「どちら側の問題か」を判断する。
      TEXT
    },
    {
      seed_key: "error.branch_stuck",
      category: error,
      title: "ブランチで詰まったとき",
      body: <<~TEXT
        現在の作業ブランチで修正できなかった場合は、
        新しいブランチを切ってリモートから前データを取得するといいよ。

        大切なのは、課題を見直してから
        「何が原因だったか」を理解すること。

        失敗したブランチと比較すると、
        エラーの正体が見えやすい。
        焦らず、ひとつずつ行こう。
      TEXT
    },
    {
      seed_key: "error.no_method_error",
      category: error,
      title: "NoMethodError",
      body: <<~TEXT
        NoMethodError は「そのメソッドを呼べない」という意味。

        まずはログに出ている行で、
        ・nil になっていないか
        ・型が想定と違っていないか
        を確認しよう。

        puts / debugger / binding.irb で
        中身を見るのが最短ルート。
      TEXT
    },

    # -------------------------
    # モチベ
    # -------------------------
    {
      seed_key: "motiva.progress_stop",
      category: motiva,
      title: "進捗が止まる理由",
      body: <<~TEXT
        動けないとき、
        だいたいタスクがデカすぎる。

        「ログイン機能作る」
        それ、広すぎ。

        分けよう。

        ・フォーム表示
        ・保存処理
        ・エラー表示

        それでも大きいなら、
        さらに半分。

        「何をもって完了？」を書いてみよう。

        例：
        ・フォームが表示される
        ・DBに保存される
        ・エラーが1つ出せる

        完璧にやろうとしてない？

        MVP思い出して。

        60点で出して、
        次で直す。

        それが本当の前進。

        比較しなくていい。
        他人は他人の森を歩いてる。

        君は君の1コミットでいい。
      TEXT
    },
    {
      seed_key: "motiva.stuck_thinking",
      category: motiva,
      title: "詰まったとき",
      body: <<~TEXT
        ……止まったね。

        まず言うね。
        これは能力不足じゃない。

        詰まりはだいたい3種類。

        ・理解がまだ繋がってない
        ・情報が足りない
        ・前提がズレてる

        まずこれやってみよう。

          git status

        今どのブランチ？
        何が変更されてる？

        次に、

          git diff

        直前に何を変えた？

        だいたい原因はそこにいる。

        それでも分からないなら、
        エラーメッセージを最初から最後まで読む。

        「読んだつもり」はダメ。
        本当に読む。

        森で迷ったら、走らない。

        今いる場所を確認する。
        それだけで半分は戻れる。
      TEXT
    },
    {
      seed_key: "motiva.error_mindset",
      category: motiva,
      title: "エラーは敵じゃない",
      body: <<~TEXT
        エラーが出ると、
        ちょっと心が縮むよね。

        でもね、
        エラーは怒ってない。

        ただ「ここ違うよ」って言ってる。

        まず見るのはこれ。

        ・ファイル名
        ・行番号
        ・undefined / nil / missing みたいな単語

        次にやること。

          tail -n 50 log/development.log

        ログを見よう。

        それでも分からなければ、

          bin/rails c

        コンソールで値を確認する。

        フロントが怪しいなら、
        F12を押してデベロッパーツール。

        ・Console に赤いエラーは出てない？
        ・Network は 200？ 500？
        ・params は送れてる？

        エラーは敵じゃない。
        読まないことが敵。

        ちゃんと向き合えば、
        必ずヒントはある。
      TEXT
    },
    {
      seed_key: "motiva.where_it_stops",
      category: motiva,
      title: "どこまで動いている？",
      body: <<~TEXT
        エラーが出たとき、
        「全部壊れた」と思いがち。

        でもね、まず確認しよう。

        どこまで動いてる？

        一時的にこう入れてみる。

          puts "🔥 ここ通った"

        ログに出れば、
        そこまでは成功している。

        出なければ、
        そこに到達していない。

        何が壊れたかより、
        どこで止まったか。

        森は全部燃えてない。
        止まった地点があるだけ。

        小さく確認して、
        小さく直す。

        それで十分。
      TEXT
    },
    {
      seed_key: "motiva.perfection_trap",
      category: motiva,
      title: "完璧主義の罠",
      body: <<~TEXT
        「もっときれいにしてから出そう」
        「まだ足りない」

        それ、分かる。

        でもね、
        完璧主義は前進を止めることがある。

        いまの目的は何？

        完成？
        それとも検証？

        MVP思い出して。

        ・動く
        ・使える
        ・壊れてない

        これで十分。

        100点を目指して止まるより、
        60点で出して改善するほうが速い。

        森は一気に完成しない。

        小さく作って、
        小さく直す。

        それが本当に強い。
      TEXT
    }
  ]

  # =========================================================
  # Advice 反映（seed管理分だけ同期）
  # =========================================================
  current_seed_keys = advices.map { |a| a[:seed_key] }

  puts "🧹 Cleaning old seeded Advice..."
  Advice.where.not(seed_key: current_seed_keys).where.not(seed_key: nil).destroy_all

  advices.each do |data|
    Advice.find_or_initialize_by(seed_key: data[:seed_key]).tap do |a|
      a.category = data[:category]
      a.title    = data[:title]
      a.body     = data[:body]
      a.save!
    end
  end
end

puts "🌱 seeds.rb completed: Advice & Category updated"
