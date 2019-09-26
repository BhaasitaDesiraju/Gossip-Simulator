defmodule Topologies do

  # Full Topology
  def fullTopology(node_list) do
    #Delete current node from list of nodes
    Enum.each(node_list, fn(x) ->
    list_of_nodes = List.delete(node_list, x)
    IO.inspect(list_of_nodes)
    #handle GenServer call
    end)
  end

  # Line Topology
  def lineTopology(node_list) do
  nodes_length = length(node_list)
  start_val = 0
  end_val = (nodes_length - 1)
  Enum.each(node_list, fn(x) ->
    index = Enum.find_index(node_list,fn(i) -> i==x end)
    adjlist = []
    cond do
      index < end_val && index > start_val ->
        n1 = Enum.at(node_list,index-1)
        n2 = Enum.at(node_list,index+1)
        adjlist = adjlist ++ [n1,n2]
        IO.inspect(adjlist)
        # Genserver call
      index == start_val ->
        n2 = Enum.at(node_list,index+1)
        adjlist = adjlist ++ [n2]
        IO.inspect(adjlist)
        # Genserver call
      true->
        n1 = Enum.at(node_list,index-1)
        adjlist = adjlist ++ [n1]
        IO.inspect(adjlist)
        # Genserver call
    end
  end)
end

def create_array(length, list \\ []) do
  if length == 0 do
    list
else
  length-1 |> create_array([:rand.uniform() |> Float.round(2) | list])
end
end

def createRandom2DCoordinates(nodes) do
  length = Enum.count(nodes)
  x = create_array(length)
  y = create_array(length)
  coordinates = Enum.zip(x, y)
end

def check_neighbours(c, p) do
  {a, b} = p
  {p, q} = c
  first = :math.pow((a-p), 2)
  last = :math.pow((b-q), 2)
  radii = :math.pow(first + last, 1/2)
  if radii <= 0.1 and radii > 0 do
    true
  else
    false
  end
end


# ???? If an actor has no neighbours? - Then should we include it in gossip communication?
#If yes, then how?

# ???? Should we rearrange the position of the actor to involve it in the communication?

#There cannot be actors without neighbours - placement should be such that each actor has neighbours

#If an actor has no neighbours - then do not involve it in the communication and
#also do not count the number of times
#gossip is being circulated

#Push sum has a terminating criteria for actors that donot actively communicate
#this boundary condition has to be handled only for gossip

def random2DTopology(nodes) do
  list = createRandom2DCoordinates(nodes)
  Enum.each(nodes, fn x ->
    i = Enum.find_index(nodes, fn b -> b == x end)
    c = Enum.fetch!(list, i)
    num_nodes = Enum.count(nodes)
    n_list = Enum.filter((0..num_nodes-1), fn y -> check_neighbours(c, Enum.at(list, y)) end)
    adjlist = Enum.map_every(n_list, 1, fn x -> Enum.at(nodes, x) end)
    IO.inspect adjlist, charlists: :as_lists
    # List.flatten(adjlist)
    #Proj2.add_to_adjList(x,adjlist)
  end)
end




end
