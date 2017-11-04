# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rails db:seed command (or created alongside the database with db:setup).
#
# Examples:
#
#   movies = Movie.create([{ name: 'Star Wars' }, { name: 'Lord of the Rings' }])
#   Character.create(name: 'Luke', movie: movies.first)
u1 = User.create(name: 'avery', email: 'avery@test.com', password: 'admin1234')
u2 = User.create(name: 'avery2', email: 'avery2@test.com', password: 'admin1234')

a1 = Alias.create(user_id: u1.id, effective_date: Date.today)
a2 = Alias.create(user_id: u2.id, effective_date: Date.today)

MatchedAlias.create(alias_1_id: a1.id, alias_2_id: a2.id, effective_date: Date.today)


Article.create(alias_id: a1.id, title: "Title Test", body: "Body Test")
Article.create(alias_id: a2.id, title: "Title Test 2", body: "Body Test 2")
