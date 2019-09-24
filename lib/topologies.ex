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



end
