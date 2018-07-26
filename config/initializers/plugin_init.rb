# plugin initialization
t = Tab.new("friendings", "friendings", "/tab/friendings")
# add any subtabs with what you need. params are controller and the label, for example
t.add("index", "friend users")
t.add("requests", "requests")