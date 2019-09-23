defmodule Topologies do

  #Full Topology
  def fullTopology(node_list) do
    #Delete current node from list of nodes
    Enum.each(node_list, fn(x) ->
    list_of_nodes = List.delete(node_list, x)
    #handle GenServer call
    end)
  end

  #Line Topology
  def lineTopology(node_list, node_list_length, node_Id) do
    cond do
    node_Id == 1 -> neighbour = [node_Id+1]
    node_Id == node_list_length -> neighbour = [node_Id-1]
    true -> neighbour = [node_Id+1, node_Id-1]
    #Handle genserver call
  end
end

end
