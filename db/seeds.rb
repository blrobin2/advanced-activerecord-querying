developer = Role.create(name: 'Developer', billable: true)
manager = Role.create(name: 'Manager', billable: false)

developer.people.create(name: 'Wendell')
developer.people.create(name: 'Christie')
manager.people.create(name: 'Eve')
