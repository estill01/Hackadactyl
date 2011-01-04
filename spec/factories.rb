Factory.sequence :name do |n|
  "username#{n}"
end

Factory.sequence :email do |n|
  "basic_email#{n}@gmail.com"
end



Factory.define :finish do |c|
  c.name "A finish"
  c.position 1
  c.association :finish_category, :factory => :finish_category
end
Factory.define :user do |u|
  u.first_name "John"
  u.last_name "Doe"
  u.username { Factory.next(:name) }
  u.email { Factory.next(:email) }
  u.password "password"
  u.password_confirmation "password"
end

Factory.define :admin, :parent => :user do |p|
end
Factory.define :client do |c|
  c.first_name "Matthew"
  c.last_name "Bergman"
  c.email { Factory.next(:email) }
end
