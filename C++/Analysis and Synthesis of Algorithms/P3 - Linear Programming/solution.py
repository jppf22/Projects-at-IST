from pulp import *

prob = LpProblem("Santa_Factory_Problem", LpMaximize)

num_toys,num_packs,max_toys = map(int, input().split())

toys_vars = []
toys_individual_profit = []
toys_upbound = []
total_toy_appearances = []
pack_vars = []
pack_contents = []
packs_profit = []

for toy in range(1, num_toys + 1):
    name = f"toy{toy}"
    profit, up_bound = map(int, input().split())
    toys_upbound.append(up_bound)
    toys_vars.append(LpVariable(name, 0,up_bound,cat='Integer'))
    toys_individual_profit.append(profit)
    total_toy_appearances.append(toys_vars[-1])

for pack in range(1, num_packs + 1):
    name = f"pack{pack}"
    pack_toy1, pack_toy2, pack_toy3, pack_profit = map(int, input().split())
    pack_vars.append(LpVariable(name, 0, min(toys_upbound[pack_toy1-1],toys_upbound[pack_toy2-1],toys_upbound[pack_toy3-1]),cat='Integer'))
    total_toy_appearances[pack_toy1-1] += pack_vars[-1]
    total_toy_appearances[pack_toy2-1] += pack_vars[-1]
    total_toy_appearances[pack_toy3-1] += pack_vars[-1]
    pack_contents.append([pack_toy1, pack_toy2, pack_toy3])
    packs_profit.append(pack_profit)

prob += (
    lpSum(toys_individual_profit[i]*toys_vars[i] for i in range(num_toys)) 
    + lpSum(packs_profit[j]*pack_vars[j] for j in range(num_packs))
)

prob += lpSum(toys_vars) + 3*lpSum(pack_vars) <= max_toys

for i in range(num_toys):
    prob += total_toy_appearances[i] <= toys_upbound[i]

status = prob.solve(GLPK(msg=0))

print(value(prob.objective))