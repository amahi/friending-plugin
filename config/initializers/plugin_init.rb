# plugin initialization
t = Tab.new("friendings", "friends", "/tab/friends")
# add any subtabs with what you need. params are controller and the label, for example
t.add("index", "users")
t.add("requests", "requests")