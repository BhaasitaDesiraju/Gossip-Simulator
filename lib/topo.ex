defmodule Topo do
  def generate_array(length, list \\ []) do
    if length == 0 do
      list
  else
    length-1 |> generate_array([:rand.uniform() |> Float.round(2) | list])
  end
  end

  def create_coordinates(nodes) do
    length = Enum.count(nodes)
    x = generate_array(length)
    y = generate_array(length)
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

  #If an actor has no neighbours - then do not involve it in the communication and
  #also do not count the number of times
  #gossip is being circulated

  #Push sum has a terminating criteria for actors that donot actively communicate
  #this boundary condition has to be handled only for gossip

  def buildRand2D(nodes) do
    list = create_coordinates(nodes)
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
