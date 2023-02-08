# README

Welcome to Open-Piggy, my first open source project.

* Get repository

```shell
git clone https://github.com/santannalucas/Piggy.git
```

* Ruby version

This app uses Ruby 3.0.0 and Rails ~> 7.0, be sure to change you version manager to version 3 and that you have rails 7 installed:

```shell
user@ubuntu:~/piggy$ rvm use ruby-3.0.0
Using /home/lucas/.rvm/gems/ruby-3.0.0

user@ubuntu:~/piggy$ ruby -v
ruby 3.0.0p0 (2020-12-25 revision 95aff21468) [x86_64-linux]

user@ubuntu:~/piggy$ rails -v
Rails 7.0.4.2

```

* Database creation

Application use PostgreSQL Database by default, but you should not have significant impact if using MySQL or SQLite. Just be sure to check the queries syntax.

Database configuration should look like this:
```yml
default: &default
  adapter: postgresql
  host: localhost
  username: piggy
  password: piggy_pass

development:
  <<: *default
  database: piggy

test:
  <<: *default
  database: piggy_test
```

* Database initialization

Create, Migrate DB and run the seed to create application initial data
This will create the initial user, to change user name, password and email, update data on first line of seed file: https://github.com/santannalucas/Piggy/blob/main/db/seeds.rb

1. Update Admin User details

```ruby
  User.create(name:"Initial User", password:'Init123', email:'piggy.onrails@gmail.com', role_id:1, active: true)
```

2.Create / Migrate / Seed DB

```bash
rake db:create
rake db:migrate
rake db:seed
```

* First Access / How to run the test suite


