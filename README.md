# README

## Intro
Welcome to Open-Piggy, my first open source project.

Always under construction, currently on the works:

- Documentation and Test Unit
- Enhanced Reports
- Organising JS - Removing view script and using async calls
- API gate for React standalone front-end
- Mailer for password renew, 2 step-authentication and scheduled bills notification
- General code styling and naming/comment review to increase easiness of code reading and navigation

## Installing

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

## Database and APP initialization

Create, Migrate DB and run the seed to create application initial data
This will create the initial user, to change user name, password and email, update data on first line of seed file: https://github.com/santannalucas/Piggy/blob/main/db/seeds.rb

1. Update Admin User details

```ruby
  User.create(name:"Initial User", password:'Init123', email:'piggy.onrails@gmail.com', role_id:1, active: true)
```

2. Create / Migrate / Seed DB

```bash
rake db:create
rake db:migrate
rake db:seed
```

3. Seed Demo user

In case you want to generate the demo user, which contains a set of transactions for the years 2022 and 2023. Rename /db/seeds.rb to /db/initial_seeds.db, rename /db/demo_user_seeds.rb to seeds.rb and run rake db:seed again:

```bash
mv seeds.rb initial_seeds.rb
mv demo_user_seeds.rb seeds.rb
rake db:seed
``` 

### DEMONSTRATION USER
- username: demo.user@piggy.onrails.com
- password: Init123

Demo User has no access to System Admin Workspace.

4. Run the server
```bash
  rails s
```
5. Open App

   http://localhost:3000/

## First Access 

Steps on How to configure and use after your first access are available at the Open Piggy Wiki on Github:
https://github.com/santannalucas/Piggy/wiki
