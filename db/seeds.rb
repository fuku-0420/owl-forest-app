# =========================
# Owl（フクちゃん）
# =========================
Owl.find_or_create_by!(name: "フクちゃん") do |owl|
  owl.species     = "学習サポートフクロウ"
  owl.age         = 26
  owl.habitat     = "RUNTEQ 知識の森"
  owl.description = "学習者に寄り添い、つまずきをやさしく案内してくれるフクロウ"
end

# =========================
# Category（黒板に並ぶ項目）
# =========================
categories = [
  [ "エラー",   "よくあるエラーと対処" ],
  [ "Rails",    "Railsで詰まりやすい点" ],
  [ "SQL",      "DB/SQLのつまずき" ],
  [ "設計",     "責務分割・設計の悩み" ],
  [ "学習法",   "学び方・進め方" ],
  [ "モチベ",   "不安・やる気・継続" ]
]

categories.each do |name, desc|
  Category.find_or_create_by!(name: name) do |c|
    c.description = desc
  end
end

# =========================
# Category 参照
# =========================
error  = Category.find_by!(name: "エラー")
rails  = Category.find_by!(name: "Rails")
sql    = Category.find_by!(name: "SQL")
design = Category.find_by!(name: "設計")
study  = Category.find_by!(name: "学習法")
motiva = Category.find_by!(name: "モチベ")

# =========================
# Advice（エラー）
# =========================
Advice.find_or_create_by!(category: error, title: "ブランチで詰まったとき") do |a|
  a.body = <<~TEXT
    現在の作業ブランチで修正できなかった場合は、
    新しいブランチを切ってリモートから前データを取得するといいよ。

    大切なのは、課題を見直してクリアしてから
    何がエラーの原因だったのかを理解すること。

    失敗したブランチと比較してみよう。
    エラーが出ても焦らずやっていこう！
  TEXT
end

Advice.find_or_create_by!(category: error, title: "NoMethodError が出たとき") do |a|
  a.body = <<~TEXT
    NoMethodError は「そのメソッドを呼べない」という意味だよ。

    まずはログに出ている行で、
    「nilになってないか」「型が想定と違わないか」を確認しよう。

    puts / debugger / binding.irb で中身を見るのが最短ルート！
  TEXT
end

Advice.find_or_create_by!(category: error, title: "nilで落ちたときの見方") do |a|
  a.body = <<~TEXT
    nilで落ちるときは「どこでnilになったか」を逆算すると早いよ。

    例：@user.name で落ちるなら @user が nil。
    じゃあ「@user を代入してる場所」が怪しい。

    「代入 → 参照」の順で追うと迷子になりにくい！
  TEXT
end

# =========================
# Advice（Rails）
# =========================
Advice.find_or_create_by!(category: rails, title: "assetsが反映されないとき") do |a|
  a.body = <<~TEXT
    public/assets に古いファイルが残っていないか確認しよう。

    本番用アセットが原因で、
    JSやCSSが反映されないことがあるよ。

    一度削除して再起動すると解決することも多い。
  TEXT
end

Advice.find_or_create_by!(category: rails, title: "render と redirect_to で迷ったら") do |a|
  a.body = <<~TEXT
    render は「同じリクエスト内で画面を描き直す」、
    redirect_to は「別リクエストとして移動する」だよ。

    バリデーションエラーを表示したいときは render、
    正常終了して一覧へ戻すなら redirect_to が基本。
  TEXT
end

Advice.find_or_create_by!(category: rails, title: "Strong Parameters 忘れがちなやつ") do |a|
  a.body = <<~TEXT
    フォームで送った値が保存されないときは、
    strong parameters（permit）が漏れてることがよくあるよ。

    params.require(:model).permit(:name, :xxx)
    ここに追加したいカラムが入ってるかチェックしよう！
  TEXT
end

# =========================
# Advice（SQL）
# =========================
Advice.find_or_create_by!(category: sql, title: "where と find の違い") do |a|
  a.body = <<~TEXT
    find は「idで1件取得」が基本で、
    見つからないと例外になるよ。

    where は「条件検索」で、
    結果は配列（Relation）として返ってくる。

    迷ったら：
    ・1件確定 → find / find_by
    ・絞り込み → where
  TEXT
end

Advice.find_or_create_by!(category: sql, title: "N+1っぽいと感じたら") do |a|
  a.body = <<~TEXT
    一覧で関連データも表示するときに、
    画面が重いなら N+1 を疑ってみよう。

    includes(:association) を付けると
    改善することが多いよ。

    development.log にSQLが大量に出てたらかなり怪しい！
  TEXT
end

# =========================
# Advice（設計）
# =========================
Advice.find_or_create_by!(category: design, title: "責務分割で迷ったとき") do |a|
  a.body = <<~TEXT
    1つのクラスやメソッドが
    「やること多すぎ」だと感じたら分割のサインだよ。

    目安は「名前が and で繋がる」状態。
    “保存して通知してログを残す” みたいになったら分けよう。

    まずはメソッド抽出からでOK！
  TEXT
end

Advice.find_or_create_by!(category: design, title: "モデルが太ったときの逃がし先") do |a|
  a.body = <<~TEXT
    model にロジックが増えて読みにくくなったら、
    ServiceオブジェクトやFormオブジェクトに
    逃がす手があるよ。

    いきなり綺麗にしなくてOK。
    「まず動く → 後で整理」が強い。
  TEXT
end

# =========================
# Advice（学習法）
# =========================
Advice.find_or_create_by!(category: study, title: "詰まったらログと公式を見る") do |a|
  a.body = <<~TEXT
    詰まったときは「感覚でいじる」より、
    ログと公式（Rails Guides / gem README）を見る方が早いよ。

    エラー文をちゃんと読むだけで
    解けることも多い。

    急がばログ！
  TEXT
end

Advice.find_or_create_by!(category: study, title: "理解が浅いまま進んでOK") do |a|
  a.body = <<~TEXT
    全部理解してから進むのは難しいし、
    時間も溶けやすいよ。

    まず動かして、
    あとで「なぜ動いたか」を回収しよう。

    “今は仮でOK” を自分に許してあげて。
  TEXT
end

# =========================
# Advice（モチベ）
# =========================
Advice.find_or_create_by!(category: motiva, title: "やる気が出ない日は") do |a|
  a.body = <<~TEXT
    やる気が出ない日は
    「作業を小さくする」のが正解だよ。

    ・5分だけ README を触る
    ・1行だけ seed を増やす
    ・1コミットだけする

    0 → 1 を作れれば勝ち！
  TEXT
end

Advice.find_or_create_by!(category: motiva, title: "人と比べて落ちたとき") do |a|
  a.body = <<~TEXT
    比べたくなるのは、
    真面目に頑張ってる証拠だよ。

    比較対象を「他人」じゃなく
    「昨日の自分」に戻そう。

    1つでも理解が増えてたら前進。
    続けた人が勝つ！
  TEXT
end
