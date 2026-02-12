def test1():
    nodes = {
        'n1': 12,
        'n2': 10
    }

    partitions = {
        'p1': 7,
        'p2': 3
    }
    k_safety = 2

    requests = {
        ('p1', 'n1'): 1,
        ('p2', 'n1'): 1,
        ('p1', 'n2'): 2,
        ('p2', 'n2'): 2
    }
    comm_costs = {
        'p1': 4,
        'p2': 2
    }

    return nodes, partitions, k_safety, requests, comm_costs

# Do a test where comm costs are constant among one cluster and x100 between clusters
# Hot Regions: 80% of requests go to 20% of the data
# Start with two clusters, distribute requests equally
# Can start simple with equal request probability for everyone
# Second set is with a region affinity (partition affinity)
    # Montreal girls love montreal stuff more than toronto stuff but sometimeeesss they want toronto stuff