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