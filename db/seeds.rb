# Create Default Transactions Types
TransactionType.create(name:'system')
TransactionType.create(name:'deposit')
TransactionType.create(name:'expenses')

# Create Admin Role
Role.create(name: 'Admin')
Role.create(name: 'Standard Account')

# Initial User - Change Name, email and Password here.
User.create(name:"Initial User", password:'Init123', email:'piggy.onrails@gmail.com', role_id:1, active: true)

# Create Workspaces
Workspace.create(name:'Roles')
Workspace.create(name:'Workspaces')
Workspace.create(name:'Rules')
Workspace.create(name:'Custom Rules')
Workspace.create(name:'Users')
Workspace.create(name:'Accounts')
Workspace.create(name:'Bank Accounts')
Workspace.create(name:'Transactions')
Workspace.create(name:'Currencies')
Workspace.create(name:'Categories')
Workspace.create(name:'Schedulers')
Workspace.create(name:'Reports')

# Rebuild Roles
Role.rebuild
User.first.validate_options
Rule.where(role_id:2,workspace_id:(6..15).collect{|x| x}).each do |x| x.update(c:true,r:true,u:true, d:true, s:true, p:true) end




