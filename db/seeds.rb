Owl.destroy_all

Owl.find_or_create_by(name: "フクちゃん") do |owl1|
  owl1.species = "学習サポートフクロウ"
  owl1.age = 26
  owl1.habitat = "RUNTEQ 知識の森"
  owl1.description = "..."
end
