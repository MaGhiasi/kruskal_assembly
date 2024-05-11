def find_first_min(cost):
    for i in range(len(cost)):
        for j in range(len(cost)):
            if (cost[i][j]>0):
                return [i,j]

    return [-1,-1]                

def find_min(cost,a,b,min):
    for x in range(len(cost)):
        for y in range(len(cost[0])):
            if cost[x][y] < min and cost[x][y]>0:
                min = cost[x][y]
                a = x
                b = y
    return [a,b,min]            
        

def DFS (v , previous , visited , matrix):
    visited [v] = 1
    for i in range(len(matrix)):
        if matrix[v][i] > 0 :
            if (visited[i]==0):
                DFS(i , v , visited, matrix)    
            else:
                if previous!=i:
                    return 1  

def kruskalMST(cost):
    mincost = 0 
    V = len(cost)
    picked_edges = [[0 for i in range(V)] for i in range(V)]
    edge_count = 0
    while edge_count < V-1 :
        index=find_first_min(cost)
        if index[0] >=0: 
            min = cost[index[0]][index[1]]
            last_min = find_min(cost, index[0], index[1], min)
            a = last_min[0]
            b = last_min[1]
            min = last_min[2]
            #print('min',min)
            #if (min > 0):
            visited = [0 for i in range(V)]
            picked_edges[a][b] = cost[a][b]
            picked_edges[b][a] = cost[b][a]
            if (DFS(a,a, visited, picked_edges) != 1):
                print('Edge {}:({}, {}) cost:{}'.format(edge_count, a, b, min))
                edge_count += 1
                mincost += min
            else:
                #print('msg2')
                picked_edges[a][b] = 0
                picked_edges[b][a] = 0
            #print('msg4')
            cost[a][b] = 0
            cost[b][a] = 0
        #else:
        #    break    

        
    return  mincost    

# cost = [[0, 2, 0, 6, 0],
# 		[2, 0, 3, 8, 5],
# 		[0, 3, 0, 0, 7],
# 		[6, 8, 0, 0, 9],
# 		[0, 5, 7, 9, 0]]

cost = [[0, 3, 1, 6, 0, 0],
		[3, 0, 5, 0, 3, 0],
		[1, 5, 0, 5, 6, 4],
		[6, 0, 5, 0, 0, 2],
		[0, 3, 6, 0, 0, 6],
       [0, 0, 4, 2, 6, 0]]

# cost = [[0 ,50 ,60 ,0 ,0 ,0 ,0],
#         [50 ,0 ,0 ,120,90 ,0 ,0],
#         [60 ,0 ,0 ,0 ,0 ,50 ,0],
#         [0 ,120,0 ,0 ,0 ,80 ,70],
#         [0 ,90 ,0 ,0 ,0 ,0 ,40],
#         [0 ,0 ,50 ,80 ,0 ,0 ,140],
#         [0 ,0 ,0 ,70 ,40 ,140,0]]

print(kruskalMST(cost))