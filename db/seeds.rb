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
  categories = [
    [ "入門",               "プログラミング学習の最初の一歩" ],
    [ "Rails",              "Railsの仕組みと使い方" ],
    [ "SQL",                "DB/SQLのつまずき" ],
    [ "設計",               "責務分割・設計の悩み" ],
    [ "開発",               "開発作業・運用で使う知識" ],
    [ "エラー",             "よくあるエラーと対処" ],
    [ "学習",               "アルゴリズムや開発手法など、理解を広げる知識" ],
    [ "モチベ",             "不安・やる気・継続" ],
    [ "みんなのお悩み解決", "学習中のリアルな悩みを共有・解決する場所" ]
  ]

  current_category_names = categories.map(&:first)

  puts "🧹 Cleaning old categories..."
  Category.where.not(name: current_category_names).destroy_all

  categories.each do |name, desc|
    Category.find_or_initialize_by(name: name).tap do |c|
      c.description = desc
      c.save!
    end
  end

  # =========================================================
  # Category 参照
  # =========================================================
  beginner = Category.find_by!(name: "入門")
  rails    = Category.find_by!(name: "Rails")
  sql      = Category.find_by!(name: "SQL")
  design   = Category.find_by!(name: "設計")
  dev      = Category.find_by!(name: "開発")
  error    = Category.find_by!(name: "エラー")
  study    = Category.find_by!(name: "学習")
  motiva   = Category.find_by!(name: "モチベ")
  trouble  = Category.find_by!(name: "みんなのお悩み解決")

  # =========================================================
  # アドバイス定義（seed管理：seed_key を固定で持つ）
  # =========================================================
  advices = [

    # -------------------------
    # 入門
    # -------------------------
    {
      seed_key: "beginner.programming_language",
      category: beginner,
      title: "プログラミング言語",
      body: <<~TEXT
        プログラミング言語とは、コンピュータに「どう動いてほしいか」を伝えるための言葉なんだよ。

        ぼくたちがアプリを使うとき、画面の裏ではたくさんの処理が動いているよね。でもコンピュータは人間の言葉をそのまま理解できないから、その処理は専用の言葉で書いてあげる必要があるんだ。

        たとえば「データを取り出す」「画面に表示する」といった動きも、すべてこの言葉で指示されているよ。

        Railsも、このプログラミング言語のひとつであるRubyを使って動いているんだ。
      TEXT
    },
    {
      seed_key: "beginner.web_app",
      category: beginner,
      title: "Webアプリ",
      body: <<~TEXT
        Webアプリとは、インターネットを通して使うアプリのことだよ。

        大事なのは、その動き方なんだ。ユーザーが画面で操作すると、その情報はサーバーに送られて、そこで処理されるよ。

        サーバーはその内容をもとに「どんな結果を返すか」を考えて、もう一度画面に返してくれるんだ。

        つまりWebアプリとは、「操作」→「処理」→「結果表示」という流れで動いている仕組みなんだよ。

        Railsは、この中でもサーバー側の処理を作るための仕組みなんだ。
      TEXT
    },
    {
      seed_key: "beginner.database",
      category: beginner,
      title: "データベース",
      body: <<~TEXT
        データベースとは、アプリで使うデータを整理して保存しておく仕組みのことだよ。

        ユーザー情報や投稿内容は、毎回作り直されるわけじゃなくて、必要なときに取り出せるように保存されているんだ。

        アプリはこのデータベースからデータを取り出したり、新しく保存したりしながら動いているよ。

        Railsでは、このデータのやり取りをActiveRecordという仕組みで扱っているんだ。
      TEXT
    },
    {
      seed_key: "beginner.server",
      category: beginner,
      title: "サーバー",
      body: <<~TEXT
        サーバーとは、アプリの処理を実際に動かしているコンピュータのことだよ。

        ユーザーが操作すると、その情報はサーバーに送られてくるんだ。サーバーはそれを受け取って、必要な処理をして、結果を返してくれるよ。

        たとえば「一覧を見たい」と言われたら、データを集めて画面を作って返しているんだ。

        Railsは、このサーバーの中で動く仕組みなんだよ。
      TEXT
    },
    {
      seed_key: "beginner.frontend",
      category: beginner,
      title: "フロントエンド",
      body: <<~TEXT
        フロントエンドとは、ユーザーが直接見る画面の部分のことだよ。

        ボタンや入力フォームなど、実際に触れる部分はすべてここにあたるんだ。

        ユーザーの操作は、このフロントエンドを通してサーバーに送られていくよ。

        Railsで作った処理も、このフロントエンドに表示されることで、ユーザーが使える形になるんだ。
      TEXT
    },
    {
      seed_key: "beginner.backend",
      category: beginner,
      title: "バックエンド",
      body: <<~TEXT
        バックエンドとは、ユーザーからは見えない裏側の処理を担当する部分のことだよ。

        データを保存したり、取り出したり、どんな結果を返すかを判断したりと、アプリの中でも大事な処理はここで行われているんだ。

        フロントエンドから送られてきた情報を受け取って、どう動くかを決めているよ。

        Railsは、このバックエンドを作るための仕組みなんだ。
      TEXT
    },
    {
      seed_key: "beginner.ui",
      category: beginner,
      title: "UI",
      body: <<~TEXT
        UIとは、ユーザーが実際に見る見た目や、操作する部分のことだよ。

        ボタンのデザインや配置、文字の見やすさ、操作のしやすさなど、ユーザーが触れる部分はすべてUIなんだ。

        同じ機能でも、UIが分かりやすいと迷わず使えるし、分かりにくいと使いづらく感じてしまうよね。

        つまりUIとは、「どう操作するか」を決める大事な作りなんだ。
      TEXT
    },
    {
      seed_key: "beginner.ux",
      category: beginner,
      title: "UX",
      body: <<~TEXT
        UXとは、アプリを使ったときの体験全体のことだよ。

        操作がスムーズだったり、迷わず使えたりすると、「使いやすい」と感じるよね。そういう体験の良さがUXなんだ。

        UIは見た目や操作の部分だけど、UXはその一歩先にある「使ったときの感じ」を指しているよ。

        つまりUXとは、「このアプリ使いやすいな」と思えるかどうかを決める考え方なんだ。
      TEXT
    },

    # -------------------------
    # Rails
    # -------------------------
    {
      seed_key: "rails.ruby",
      category: rails,
      title: "Ruby",
      body: <<~TEXT
        Rubyとは、Railsの土台となっているプログラミング言語だよ。

        Railsは便利な仕組みだけど、その中で実際に動いている処理はすべてRubyで書かれているんだ。

        Railsに「データを取り出して」「画面を表示して」といった指示を出すときも、このRubyという言葉で書いてあげる必要があるよ。

        つまりRubyとは、Railsにやってほしいことを伝えるための言葉であり、実際にアプリを動かしている中身でもあるんだ。
      TEXT
    },
    {
      seed_key: "rails.mvc",
      category: rails,
      title: "MVC",
      body: <<~TEXT
        MVCとは、アプリの役割を分けて整理するための考え方だよ。

        アプリをそのまま作ると、データの処理や画面の表示が全部混ざってしまって、分かりにくくなってしまうんだ。

        そこで、データを扱う部分（モデル）、画面を作る部分（ビュー）、処理の流れを決める部分（コントローラー）というふうに役割を分けているよ。

        Railsは、このMVCという考え方をもとに作られているんだ。
      TEXT
    },
    {
      seed_key: "rails.routing",
      category: rails,
      title: "ルーティング",
      body: <<~TEXT
        ルーティングとは、ユーザーのアクセスと処理をつなぐ入口の仕組みのことだよ。

        ユーザーがURLにアクセスすると、その情報はまずルーティングに届くんだ。

        ルーティングは「このリクエストをどこに渡すか」を判断して、正しいコントローラーへ案内しているよ。

        つまりルーティングとは、アプリの中で道案内をしている仕組みなんだ。
      TEXT
    },
    {
      seed_key: "rails.controller",
      category: rails,
      title: "コントローラー",
      body: <<~TEXT
        コントローラーとは、アプリの処理の流れを決める役割を持つ部分だよ。

        ルーティングから受け取った情報をもとに、どのデータを使うか、どの画面を表示するかを判断しているんだ。

        モデルからデータを取り出して、それをビューに渡すという流れを作っているよ。

        つまりコントローラーとは、アプリ全体の動きをコントロールしている司令塔なんだ。
      TEXT
    },
    {
      seed_key: "rails.model",
      category: rails,
      title: "モデル",
      body: <<~TEXT
        モデルとは、データを扱うための部分のことだよ。

        データを保存したり、取り出したり、どんなルールで扱うかを決める役割があるんだ。

        Railsでは、データベースとのやり取りもこのモデルを通して行われているよ。

        つまりモデルとは、アプリのデータを管理している中心の存在なんだ。
      TEXT
    },
    {
      seed_key: "rails.view",
      category: rails,
      title: "ビュー",
      body: <<~TEXT
        ビューとは、ユーザーに見える画面を作る部分のことだよ。

        コントローラーから渡されたデータをもとに、文字やレイアウトとして表示しているんだ。

        ユーザーが実際に見る内容は、このビューで作られているよ。

        つまりビューとは、データを見える形に変える役割を持っているんだ。
      TEXT
    },
    {
      seed_key: "rails.db_link",
      category: rails,
      title: "データベース連携",
      body: <<~TEXT
        データベース連携とは、アプリとデータベースの間でデータをやり取りすることだよ。

        データを保存したり、必要な情報を取り出したりすることで、アプリの動きが成り立っているんだ。

        Railsでは、このやり取りを分かりやすく扱えるように仕組みが用意されているよ。

        その中心となるのがActiveRecordなんだ。
      TEXT
    },
    {
      seed_key: "rails.activerecord",
      category: rails,
      title: "ActiveRecord",
      body: <<~TEXT
        ActiveRecordとは、Railsでデータベースを扱いやすくするための仕組みだよ。

        本来は複雑になりやすいデータの保存や取得の処理を、シンプルに書けるようにしてくれるんだ。

        モデルと強く結びついていて、データベースとのやり取りは基本的にここを通して行われるよ。

        つまりActiveRecordとは、データ操作を分かりやすくしてくれる重要な仕組みなんだ。
      TEXT
    },
    {
      seed_key: "rails.db_change",
      category: rails,
      title: "データベース変更",
      body: <<~TEXT
        データベース変更とは、データの構造を変えることだよ。

        たとえば、新しい項目を追加したり、データの形を変えたりすることがこれにあたるんだ。

        アプリを作っていると、あとから「こうしたい」と思うことがよくあるよね。

        そういった変更を安全に行うための考え方なんだ。
      TEXT
    },
    {
      seed_key: "rails.migration",
      category: rails,
      title: "マイグレーション",
      body: <<~TEXT
        マイグレーションとは、データベース変更を記録しながら管理する仕組みだよ。

        どんな変更をいつ行ったのかを残しておくことで、あとから見返したり、同じ変更を再現したりできるんだ。

        チームで開発するときにも、とても重要な役割を持っているよ。

        つまりマイグレーションとは、データベースの変更履歴を管理する仕組みなんだ。
      TEXT
    },
    {
      seed_key: "rails.input_check",
      category: rails,
      title: "入力チェック",
      body: <<~TEXT
        入力チェックとは、ユーザーが入力したデータが正しいかどうかを確認することだよ。

        たとえば、空のまま送られていないか、短すぎないかといった確認をしているんだ。

        こうしたチェックをすることで、データの質を保つことができるよ。

        つまり入力チェックとは、正しいデータだけを扱うための大事な考え方なんだ。
      TEXT
    },
    {
      seed_key: "rails.validation",
      category: rails,
      title: "バリデーション",
      body: <<~TEXT
        バリデーションとは、Railsで入力チェックを実際に行う仕組みのことだよ。

        入力されたデータがルールに合っているかどうかを確認して、問題があれば保存されないようにしているんだ。

        モデルの中で設定されることが多く、データの正しさを守る役割を持っているよ。

        つまりバリデーションとは、入力チェックを実現するための仕組みなんだ。
      TEXT
    },
    {
      seed_key: "rails.feature_add",
      category: rails,
      title: "機能追加",
      body: <<~TEXT
        機能追加とは、アプリに新しい機能を後から加えることだよ。

        ログイン機能や検索機能など、必要に応じてアプリはどんどん成長していくよね。

        Railsでは、こうした機能を比較的簡単に追加できるようになっているんだ。

        つまり機能追加とは、アプリをより便利にしていくための取り組みなんだ。
      TEXT
    },
    {
      seed_key: "rails.gem",
      category: rails,
      title: "Gem",
      body: <<~TEXT
        Gemとは、RubyやRailsで使える機能のパーツのことだよ。

        よく使われる機能は、あらかじめパッケージとして用意されていて、それを取り入れることで簡単に使えるようになるんだ。

        自分で一から作らなくてもよくなるので、開発の効率が大きく上がるよ。

        つまりGemとは、機能追加を助けてくれる便利な部品なんだ。
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
    # 開発
    # -------------------------
    {
      seed_key: "dev.git_checkout_switch",
      category: dev,
      title: "ブランチ切替コマンド",
      body: <<~TEXT
        ブランチ操作はやっていることは似ているけど、
        コマンドの役割が違う。

        ▼ 新しく作って切り替え
          git switch -c feature/xxx

        ▼ 既存ブランチへ移動
          git switch main

        ▼ 昔の書き方
          git checkout -b feature/xxx

        checkout は色々な役割を持っていて分かりづらい。
        switch は「ブランチ操作専用」なので理解しやすい。

        基本は switch を使えばOK。
      TEXT
    },
    {
      seed_key: "dev.pr_check_min",
      category: dev,
      title: "提出前の確認",
      body: <<~TEXT
        PRを出す前に最低限これだけ確認する。

        ▼ 差分確認
          git status
          git diff

        ▼ テスト
          bin/rails test

        ▼ 静的解析（あれば）
          bundle exec rubocop

        ▼ 画面確認
          bin/rails s

        目的は「壊れているものを事前に潰すこと」。

        小さく確認してから出すと、
        レビューが通りやすくなる。
      TEXT
    },
    {
      seed_key: "dev.rubocop_a_A",
      category: dev,
      title: "自動整形",
      body: <<~TEXT
        RuboCopはコードを自動で整えてくれるツール。

        ▼ 安全な修正
          bundle exec rubocop -a

        ▼ 強力な修正（注意）
          bundle exec rubocop -A

        -A は挙動が変わる可能性がある。

        実行後は必ず確認する。

          git diff

        「直す」だけでなく、
        「何が変わったか」を見るのが大事。
      TEXT
    },
    {
      seed_key: "dev.migrate_vs_seed",
      category: dev,
      title: "migrate と seed",
      body: <<~TEXT
        migrate と seed は役割が違う。

        ▼ migrate
        データベースの構造を変える
        （テーブル・カラム追加など）

          bin/rails db:migrate

        ▼ seed
        データを入れる

          bin/rails db:seed

        流れはこれ。

        構造変更 → migrate
        データ投入 → seed
      TEXT
    },
    {
      seed_key: "dev.binrails_vs_bundleexec",
      category: dev,
      title: "Railsコマンド実行方法",
      body: <<~TEXT
        基本は bin/rails を使えばOK。

          bin/rails s
          bin/rails c
          bin/rails db:migrate

        bundle exec は、
        Gemの環境を正確に使いたいとき。

        ただし通常は bin/rails がそれをやってくれる。

        迷ったら：
        「基本は bin/rails」でOK。
      TEXT
    },
    {
      seed_key: "dev.check_value",
      category: dev,
      title: "値を確認する",
      body: <<~TEXT
        「なんでこうなった？」と思ったら、
        まず今の中身を確認してみよう。

        確認したいことは、たとえばこんなこと。
        ・データは本当に入っているか
        ・nil になっていないか
        ・思っていた形のデータになっているか

        そういうときは、一時的にこう書く。

          puts 変数名

        すると、サーバーを起動しているターミナルに中身が表示される。

        想定と違う値が出ていたら、
        その前の処理で何かがズレている可能性が高い。

        たとえば、
        ・params が取れているか
        ・DBからデータが取れているか
        ・配列だと思っていたものが nil じゃないか
        みたいなことを確認できるよ。

        似たものに grep というコマンドがあるけど、
        これは中身を見るものではなく、
        「どこにそのコードが書かれているか」を探すためのもの。

        つまり、
        grep は場所を探すもの、
        puts は中身を確認するもの。

        この2つを使い分けると、
        開発中の確認がかなりしやすくなるよ。
      TEXT
    },
    {
      seed_key: "dev.branch_stuck",
      category: dev,
      title: "ブランチで詰まったとき",
      body: <<~TEXT
        今のブランチで修正が難しくなったときは、
        無理にそのまま続けないのも大事だよ。

        たとえば、
        ・変更が複雑になりすぎた
        ・何を直したか分からなくなった
        ・別のやり方で試したくなった
        というときは、新しいブランチを切ってやり直す方が早いこともある。

        大事なのは、
        「失敗した」ではなく
        「比較できる材料が増えた」と考えること。

        前のブランチと見比べると、
        どこでズレたのかが分かりやすくなる。

        行き詰まったときは、
        その場で粘り続けるより、
        一度整理して別ルートから試すのも立派な進め方なんだ。
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
    {
      seed_key: "study.agile",
      category: study,
      title: "アジャイル開発",
      body: <<~TEXT
        アジャイル開発とは、小さく作って、早く試して、何度も改善していく開発の進め方だよ。

        最初から完璧なものを一気に作るのではなく、
        まず動くものを作って、
        使ってみて、
        問題があれば直していく。

        特徴は、
        ・変化に強い
        ・早く試せる
        ・改善を続けやすい
        というところなんだ。

        仕様が変わることも前提にしながら、
        チームで柔軟に進めていく考え方なんだよ。
      TEXT
    },
    {
      seed_key: "study.scrum",
      category: study,
      title: "スクラム",
      body: <<~TEXT
        スクラムとは、アジャイル開発を進めるための具体的な方法のひとつだよ。

        短い期間ごとに
        「作る → 確認する → 振り返る」
        をくり返していくのが特徴なんだ。

        大きな開発を一気に進めるのではなく、
        小さく区切って進めることで、
        問題に早く気づきやすくなる。

        たとえば、毎日の状況共有として
        「デイリースクラム」という短いミーティングを行うこともあるよ。

        そこでは
        ・昨日やったこと
        ・今日やること
        ・困っていること
        を共有して、チームのズレを減らしていくんだ。

        つまりスクラムとは、
        チームで協力しながら、
        小さく作って改善していくための進め方なんだよ。
      TEXT
    },
    {
      seed_key: "study.waterfall",
      category: study,
      title: "ウォーターフォール",
      body: <<~TEXT
        ウォーターフォールとは、工程を順番に進めていく開発の進め方だよ。

        たとえば、
        要件定義 → 設計 → 実装 → テスト
        というふうに、
        前の工程が終わってから次へ進むんだ。

        一つずつ順番に進めるから、計画は立てやすい。
        ただし、途中で大きく変更しにくいという特徴もあるよ。

        つまりウォーターフォールとは、
        最初に全体を決めてから、
        流れに沿って進めていく開発方法なんだ。
      TEXT
    },
    {
      seed_key: "study.critical_path",
      category: study,
      title: "クリティカルパス",
      body: <<~TEXT
        クリティカルパスとは、
        全体の作業が終わるまでの
        最短日数を決めている流れのことだよ。

        作業には、
        順番にやるものと、
        同時に進められるものがある。

        その中で、
        一番時間がかかるルートが
        全体の完了日、つまり最短日数になる。

        これがクリティカルパス。

        ポイントは、
        「重要そうな作業」ではなく、
        「全体の日数を実際に決めている流れ」を見つけることなんだ。
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
        エラーが出たら、まず
        「どこで問題が起きているか」を判断する。

        ▼ 確認方法
        F12を押して「Network」タブを見る

        ▼ ステータスの見方
        ・200 → 正常（通信は成功している）
        ・400 → リクエストの問題（URL・入力など）
        ・500 → サーバーエラー（コードの問題）

        ▼ 判断の流れ
        ① まずステータスを見る
        ② 500ならコードを疑う
        ③ 400なら入力やURLを疑う

        いきなりコードを見ずに、
        まず「どこが原因か」を切り分けるのが大事。
      TEXT
    },
    {
      seed_key: "error.no_method_error",
      category: error,
      title: "NoMethodError",
      body: <<~TEXT
        「そのメソッドは使えない」というエラー。

        ▼ よくある原因
        ・nilに対して呼んでいる
        ・型が違う
        ・スペルミス

        ▼ 確認方法
        エラーに出ている行を見る

        そのあと：

          puts 変数名

        で中身を確認する

        ▼ ポイント
        「何に対して呼んでいるか」を見る

        nilなら、
        その前の処理で値が入っていない。
      TEXT
    },
    {
      seed_key: "error.log_reading",
      category: error,
      title: "ログの見方",
      body: <<~TEXT
        エラーが出たら、
        ログを見ると原因が分かることが多い。

        ▼ 確認方法
        サーバーを起動しているターミナルを見る
        （bin/rails s を実行した画面）

        ▼ 見るポイント
        ・エラーの種類
        ・ファイル名
        ・行番号

        ▼ よくあるミス
        画面のエラーだけ見て終わる

        実際の原因はログにしか出ていないこともある。

        画面 → ヒント
        ログ → 本体

        というイメージ。
      TEXT
    },
    {
      seed_key: "error.message_reading",
      category: error,
      title: "エラーメッセージの読み方",
      body: <<~TEXT
        エラーメッセージは
        「何が起きたか」をそのまま説明している。

        ▼ 読み方の順番
        ① エラー名を見る
          → 何の問題か分かる

        ② ファイルと行番号を見る
          → どこで起きたか分かる

        ③ 内容を見る
          → 何が足りないか分かる

        ▼ 例
        undefined method
        → メソッドが存在しない

        nil
        → 値が入っていない

        ▼ ポイント
        英語を読むというより、
        「状況を理解する」感覚で見る

        1行ずつ読むと、
        かなりヒントがある。
      TEXT
    },
    {
      seed_key: "error.where_it_stops",
      category: error,
      title: "どこで止まっている？",
      body: <<~TEXT
        エラーのときは、
        「どこまで動いているか」を確認する。

        ▼ 方法
        コードの途中にこう書く：

          puts "ここ通った"

        ▼ 確認方法
        まずはサーバーを起動しているターミナルを見る。
        そこに「ここ通った」と表示されれば、
        その処理までは動いている。

        ▼ 結果
        ・表示される → そこまでは正常
        ・表示されない → その前で止まっている

        ▼ 注意
        画面（ブラウザ）には表示されない。

        ▼ 補足
        フロント側の確認をしたいときは、
        F12を押して開発者ツールの Console を見ることもある。
        ただし puts 自体は基本的にサーバー側のターミナルに出ると考えておけばOK。

        ▼ ポイント
        「どこで壊れたか」ではなく
        「どこで止まったか」で考えると見つけやすい。
      TEXT
    },
    {
      seed_key: "error.front_back",
      category: error,
      title: "フロントかバックか",
      body: <<~TEXT
        エラーが出たら、
        まず場所を判断する。

        ▼ 確認方法
        F12 → Console / Network

        ▼ 判断
        ・Consoleにエラー → フロント
        ・500エラー → バック

        ▼ 例
        ・ボタンが反応しない → フロント
        ・データが取れない → バック

        ▼ ポイント
        最初に場所を間違えると、
        ずっとズレたまま調べることになる。
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

        森は一気にはできない。

        最初は小さな種から始まって、
        芽が出て、
        少しずつ育って、
        やがて木になる。

        その木がまた実をつけて、
        種を落として、
        また新しい芽が出る。

        そうした小さな積み重ねが続いて、
        少しずつ森になっていく。

        成長は一度で完成するものじゃない。
        小さく作って、
        小さく直して、
        また育てていく。

        それが本当に強い。
      TEXT
    }

  ]

  # =========================================================
  # アドバイス反映（seed管理分だけ同期）
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
