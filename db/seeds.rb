# フクちゃん
Owl.find_or_create_by!(name: "フクちゃん") do |owl1|
  owl1.species = "学習サポートフクロウ"
  owl1.age = 26
  owl1.habitat = "RUNTEQ 知識の森"
  owl1.description = "学習者に寄り添い、つまずきをやさしく案内してくれるフクロウ"
end

# カテゴリ（黒板に並ぶ項目）
categories = [
  ["エラー", "よくあるエラーと対処"],
  ["Rails", "Railsで詰まりやすい点"],
  ["SQL", "DB/SQLのつまずき"],
  ["設計", "責務分割・設計の悩み"],
  ["モチベ", "不安・やる気・継続"],
  ["学習法", "学び方・進め方"],
]

categories.each do |name, desc|
  Category.find_or_create_by!(name: name) do |c|
    c.description = desc
  end
end
