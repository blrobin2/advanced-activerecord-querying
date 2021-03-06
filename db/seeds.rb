developer = Role.create(name: 'Developer', billable: true)
manager = Role.create(name: 'Manager', billable: false)

east = Region.create(name: 'East')
west = Region.create(name: 'West')

boston = east.locations.create(name: 'Boston')
new_york = east.locations.create(name: 'New York')
denver = west.locations.create(name: 'Denver')

eve = manager.people.create(name: 'Eve', location: new_york, salary: 50_000)
bill = manager.people.create(name: 'Bill', location: boston, salary: 40_000)

developer.people.create(name: 'Wendell', location: boston, manager: eve, salary: 35_000)
developer.people.create(name: 'Christie', location: boston, manager: eve, salary: 30_000)
developer.people.create(name: 'Sandy', location: denver, manager: bill, salary: 45_000)
