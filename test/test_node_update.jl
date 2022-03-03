#Value Children
x1 = HGF.Node(name = "x1")
x2 = HGF.Node(name = "x2")

#Volatility Children
x3 = HGF.Node(name = "x3")
x4 = HGF.Node(name = "x4")

#Test node 
xmain = HGF.Node(name = "xmain")

#Value Parents
x5 = HGF.Node(name = "x5")
x6 = HGF.Node(name = "x6")

#Volatility Parents
x7 = HGF.Node(name = "x7")
x8 = HGF.Node(name = "x8")


xmain.value_parents = [x5, x6]

update_node(xmain)