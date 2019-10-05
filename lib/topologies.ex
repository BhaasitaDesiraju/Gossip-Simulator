defmodule Topologies do
  # Full Topology
  def fullTopology(nodeList) do
    # Delete current node from list of nodes
    Enum.each(nodeList, fn x ->
      list_of_nodes = List.delete(nodeList, x)
      # GenServer call
      Project2.updateAdjList(x, list_of_nodes)
    end)
  end

  # Line Topology
  def lineTopology(nodeList) do
    nodes_length = length(nodeList)
    start_val = 0
    end_val = nodes_length - 1

    Enum.each(nodeList, fn x ->
      index = Enum.find_index(nodeList, fn i -> i == x end)
      adjlist = []

      cond do
        index < end_val && index > start_val ->
          n1 = Enum.at(nodeList, index - 1)
          n2 = Enum.at(nodeList, index + 1)
          adjlist = adjlist ++ [n1, n2]
          # IO.inspect(adjlist)
          # Genserver call
          Project2.updateAdjList(x, adjlist)

        index == start_val ->
          n2 = Enum.at(nodeList, index + 1)
          adjlist = adjlist ++ [n2]
          # IO.inspect(adjlist)
          # Genserver call
          Project2.updateAdjList(x, adjlist)

        true ->
          n1 = Enum.at(nodeList, index - 1)
          adjlist = adjlist ++ [n1]
          # IO.inspect(adjlist)
          # Genserver call
          Project2.updateAdjList(x, adjlist)
      end
    end)
  end

  def create_array(listLength, nodeList \\ []) do
    if listLength == 0 do
      nodeList
    else
      (listLength - 1) |> create_array([:rand.uniform() |> Float.round(2) | nodeList])
    end
  end

  def createRandom2DCoordinates(nodeList) do
    listLength = Enum.count(nodeList)
    x = create_array(listLength)
    y = create_array(listLength)
    xycoordinates = Enum.zip(x, y)
  end

  def check_neighbours(node1, node2) do
    {neighbor1, neighbor2} = node2
    {node2, node3} = node1
    first = :math.pow(neighbor1 - node2, 2)
    last = :math.pow(neighbor2 - node3, 2)
    radii = :math.pow(first + last, 1 / 2)

    if radii <= 0.1 and radii > 0 do
      true
    else
      false
    end
  end

  def random2DTopology(nodeList) do
    list = createRandom2DCoordinates(nodeList)

    Enum.each(nodeList, fn x ->
      i = Enum.find_index(nodeList, fn b -> b == x end)
      c = Enum.fetch!(list, i)
      num_nodes = Enum.count(nodeList)

      neighbourList =
        Enum.filter(0..(num_nodes - 1), fn y -> check_neighbours(c, Enum.at(list, y)) end)

      adjlist = Enum.map_every(neighbourList, 1, fn x -> Enum.at(nodeList, x) end)
      # IO.inspect adjlist, charlists: :as_lists
      # List.flatten(adjlist)
      Project2.updateAdjList(x, adjlist)
    end)
  end

  # 3D Start
  def buildtorus3D(nodelist) do
    # totnodes = getPerfectCube(Enum.count(nodelist1))
    # nodelist = Enum.slice(nodelist1, 1..totnodes)
    totnodes = Enum.count(nodelist)

    Enum.each(nodelist, fn x ->
      neighborlist = []
      index_node = Enum.find_index(nodelist, fn y -> y == x end)

      # For all right plane nodes
      neighborlist =
        if(rightplane(index_node, totnodes)) do
          neighbor1 =
            if(index_node - 1 >= 0) do
              Enum.fetch!(nodelist, index_node - 1)
              # else
              #   []
            end

          neighborlist = neighborlist ++ [neighbor1]
          tornode = trunc(:math.pow(totnodes, 1 / 3)) - 1

          neighbor2 =
            if(index_node - tornode >= 0) do
              Enum.fetch!(nodelist, index_node - tornode)
              # else
              #   []
            end

          neighborlist = neighborlist ++ [neighbor2]
          neighborlist
        else
          neighborlist
        end

      # For all left plane nodes
      neighborlist =
        if(leftplane(index_node, totnodes)) do
          neighbor3 =
            if(index_node + 1 < totnodes) do
              Enum.fetch!(nodelist, index_node + 1)
              #  else
              #    []
            end

          neighborlist = neighborlist ++ [neighbor3]
          tornode = trunc(:math.pow(totnodes, 1 / 3)) - 1

          neighbor4 =
            if(index_node + tornode < totnodes) do
              Enum.fetch!(nodelist, index_node + tornode)
              # else
              #   []
            end

          neighborlist = neighborlist ++ [neighbor4]
          neighborlist
        else
          neighborlist
        end

      # For all nodes that are neither right nor left
      neighborlist =
        if(!leftplane(index_node, totnodes) && !rightplane(index_node, totnodes)) do
          neighbor5 =
            if(index_node - 1 >= 0) do
              Enum.fetch!(nodelist, index_node - 1)
              # else
              #   []
            end

          neighborlist = neighborlist ++ [neighbor5]

          neighbor6 =
            if(index_node + 1 < totnodes) do
              Enum.fetch!(nodelist, index_node + 1)
              # else
              #   []
            end

          neighborlist = neighborlist ++ [neighbor6]
          neighborlist
        else
          neighborlist
        end

      # For all nodes in the top plane
      neighborlist =
        if(topplane(index_node, totnodes)) do
          finder = trunc(:math.pow(totnodes, 1 / 3))
          finder = finder * finder

          neighbor7 =
            if(index_node - finder >= 0) do
              Enum.fetch!(nodelist, index_node - finder)
              #  else
              #    []
            end

          neighborlist = neighborlist ++ [neighbor7]
          cuberoot = trunc(:math.pow(totnodes, 1 / 3))
          square = cuberoot * cuberoot
          layers = cuberoot - 1
          tornode = square * layers

          neighbor8 =
            if(index_node - tornode >= 0) do
              Enum.fetch!(nodelist, index_node - tornode)
              # else
              #   []
            end

          neighborlist = neighborlist ++ [neighbor8]
          neighborlist
        else
          neighborlist
        end

      # For all nodes in the bottom plane
      neighborlist =
        if(bottomplane(index_node, totnodes)) do
          finder = trunc(:math.pow(totnodes, 1 / 3))
          finder = finder * finder

          neighbor9 =
            if(index_node + finder < totnodes) do
              Enum.fetch!(nodelist, index_node + finder)
              # else
              #   []
            end

          neighborlist = neighborlist ++ [neighbor9]
          cuberoot = trunc(:math.pow(totnodes, 1 / 3))
          square = cuberoot * cuberoot
          layers = cuberoot - 1
          tornode = square * layers

          neighbor10 =
            if(index_node + tornode < totnodes) do
              Enum.fetch!(nodelist, index_node + tornode)
              # else
              # []
            end

          neighborlist = neighborlist ++ [neighbor10]
          neighborlist
        else
          neighborlist
        end

      # For all nodes that are neither top nor bottom nodes
      neighborlist =
        if(!bottomplane(index_node, totnodes) && !topplane(index_node, totnodes)) do
          finder = trunc(:math.pow(totnodes, 1 / 3))
          finder = finder * finder

          neighbor11 =
            if(index_node + finder < totnodes) do
              Enum.fetch!(nodelist, index_node + finder)
              # else
              #   []
            end

          neighborlist = neighborlist ++ [neighbor11]

          neighbor12 =
            if(index_node - finder >= 0) do
              Enum.fetch!(nodelist, index_node - finder)
              # else
              #   []
            end

          neighborlist = neighborlist ++ [neighbor12]
          neighborlist
        else
          neighborlist
        end

      # For all nodes in the front plane
      neighborlist =
        if(frontplane(index_node, totnodes)) do
          finder = trunc(:math.pow(totnodes, 1 / 3))

          neighbor13 =
            if(index_node + finder <= totnodes) do
              Enum.fetch!(nodelist, index_node + finder)
              # else
              #   []
            end

          neighborlist = neighborlist ++ [neighbor13]
          cuberoot = trunc(:math.pow(totnodes, 1 / 3))
          square = cuberoot * cuberoot
          tornode = square - cuberoot

          neighbor14 =
            if(index_node + tornode <= totnodes) do
              Enum.fetch!(nodelist, index_node + tornode)
              # else
              #   []
            end

          neighborlist = neighborlist ++ [neighbor14]
          neighborlist
        else
          neighborlist
        end

      # For all nodes in the back plane
      neighborlist =
        if(backplane(index_node, totnodes)) do
          finder = trunc(:math.pow(totnodes, 1 / 3))

          neighbor15 =
            if(index_node - finder >= 0) do
              Enum.fetch!(nodelist, index_node - finder)
              # else
              #   []
            end

          neighborlist = neighborlist ++ [neighbor15]
          cuberoot = trunc(:math.pow(totnodes, 1 / 3))
          square = cuberoot * cuberoot
          tornode = square - cuberoot

          neighbor16 =
            if(index_node - tornode >= 0) do
              Enum.fetch!(nodelist, index_node - tornode)
              # else
              #   []
            end

          neighborlist = neighborlist ++ [neighbor16]
          neighborlist
        else
          neighborlist
        end

      # For all the nodes that are neither in back nor front plane
      neighborlist =
        if(!frontplane(index_node, totnodes) && !backplane(index_node, totnodes)) do
          finder = trunc(:math.pow(totnodes, 1 / 3))

          neighbor17 =
            if(index_node - finder >= 0) do
              Enum.fetch!(nodelist, index_node - finder)
              # else
              #   []
            end

          neighborlist = neighborlist ++ [neighbor17]

          neighbor18 =
            if(index_node + finder < totnodes) do
              Enum.fetch!(nodelist, index_node + finder)
              # else
              #   []
            end

          neighborlist = neighborlist ++ [neighbor18]
          neighborlist
        else
          neighborlist
        end

      # IO.inspect neighborlist, charlists: :as_lists
      Project2.updateAdjList(x, Enum.filter(neighborlist, &(!is_nil(&1))))
    end)
  end

  ###############################################################################

  # To find all the nodes on the right plane
  def rightplane(index, totnodes) do
    cuberoot = trunc(:math.pow(totnodes, 1 / 3))
    square = cuberoot * cuberoot
    pos = rem(index, square)
    # return true for 3,6,9,12,15,18,21,24,27(extreme right) nodes
    if(rem(pos + 1, cuberoot) == 0) do
      true
    else
      false
    end
  end

  # To find all the nodes on the left plane
  def leftplane(index, totnodes) do
    cuberoot = trunc(:math.pow(totnodes, 1 / 3))
    square = cuberoot * cuberoot
    pos = rem(index, square)
    # return true for 1,4,7,10,13,16,19,22,25(extreme left) nodes
    if(rem(pos, cuberoot) == 0) do
      true
    else
      false
    end
  end

  # To find all the nodes on the top plane
  def topplane(index, totnodes) do
    cuberoot = trunc(:math.pow(totnodes, 1 / 3))
    square = cuberoot * cuberoot
    # return true for 19,20,21,22,23,24,25,26,27(extreme top) nodes
    if(index + square >= totnodes) do
      true
    else
      false
    end
  end

  # To find all the nodes on the botton plane
  def bottomplane(index, totnodes) do
    cuberoot = trunc(:math.pow(totnodes, 1 / 3))
    square = cuberoot * cuberoot
    # return true for 1,2,3,4,5,6,7,8,9(extreme bottom) nodes
    if(index < square) do
      true
    else
      false
    end
  end

  # To find all the nodes on the front plane
  def frontplane(index, totnodes) do
    cuberoot = trunc(:math.pow(totnodes, 1 / 3))
    square = cuberoot * cuberoot
    pos = rem(index, square)
    # return true for 1,2,3,10,11,12,19,20,21(extreme front) nodes
    if(pos < cuberoot) do
      true
    else
      false
    end
  end

  # To find all the nodes on the back plane
  def backplane(index, totnodes) do
    cuberoot = trunc(:math.pow(totnodes, 1 / 3))
    square = cuberoot * cuberoot
    pos = rem(index, square)
    # return true for 7,8,9,16,17,18,25,26,27 (extreme back) nodes
    if(pos >= square - cuberoot) do
      true
    else
      false
    end
  end

  # Project2.updateAdjList(x, neighborlist)
  # def getPerfectCube(totnodes) do
  #   cuberoot = trunc(:math.pow(totnodes, 1/3))
  #   perfectCube = cuberoot * cuberoot * cuberoot
  #   perfectCube
  # end
  # 3D End

  # honeycomb start
  # if i+j % 2 == 0 -> if x+n < n2  -> x+n is neighbor
  def isFirst(i, j, index_node, sqroot, totnodes, nodelist) do
    if(rem(i + j, 2) == 0) do
      if(index_node + sqroot < totnodes) do
        [Enum.fetch!(nodelist, index_node + sqroot)]
      else
        []
      end
    else
      []
    end
  end

  # if i+j % 2 == 1 and x-n > 0  -> x-n is neighbor
  def isLast(i, j, index_node, sqroot, totnodes, nodelist) do
    if(rem(i + j, 2) == 1) do
      if(index_node - sqroot >= 0) do
        [Enum.fetch!(nodelist, index_node - sqroot)]
      else
        []
      end
    else
      []
    end
  end

  # if isFirst() -> x+1 is neighbor
  def firstColumnCheck(i, j, index_node, sqroot, totnodes, nodelist) do
    if j == 0 do
      if index_node + 1 < totnodes do
        [Enum.fetch!(nodelist, index_node + 1)]
      else
        []
      end
    else
      []
    end
  end

  # if isLast() -> x-1 is neighbor
  def lastColumnCheck(i, j, index_node, sqroot, totnodes, nodelist) do
    if j == sqroot - 1 do
      if index_node - 1 > 0 do
        [Enum.fetch!(nodelist, index_node - 1)]
      else
        []
      end
    else
      []
    end
  end

  # if !isFirst() && !isLast() -> x+1, x-1 are neighbors
  def adjacentNeighbors(i, j, index_node, sqroot, totnodes, nodelist) do
    if j > 0 && j < sqroot - 1 do
      if index_node + 1 < totnodes && index_node - 1 >= 0 do
        [Enum.fetch!(nodelist, index_node + 1)] ++ [Enum.fetch!(nodelist, index_node - 1)]
      else
        []
      end
    else
      []
    end
  end

  def buildhoneycomb(nodelist) do
    # Requires a perfect square number of nodes
    totnodes = Enum.count(nodelist)
    sqroot = round(:math.pow(totnodes, 1 / 2))
    counter = 0..(sqroot - 1)
    ilist = Enum.to_list(counter)
    jlist = Enum.to_list(counter)

    neighborlist = []

    Enum.map(ilist, fn i ->
      nlist =
        Enum.map(jlist, fn j ->
          index_node = i * sqroot + j
          neighborlist = neighborlist ++ isFirst(i, j, index_node, sqroot, totnodes, nodelist)
          neighborlist = Enum.filter(neighborlist, &(!is_nil(&1)))
          neighborlist = neighborlist ++ isLast(i, j, index_node, sqroot, totnodes, nodelist)
          neighborlist = Enum.filter(neighborlist, &(!is_nil(&1)))

          neighborlist =
            neighborlist ++ firstColumnCheck(i, j, index_node, sqroot, totnodes, nodelist)

          neighborlist = Enum.filter(neighborlist, &(!is_nil(&1)))

          neighborlist =
            neighborlist ++ lastColumnCheck(i, j, index_node, sqroot, totnodes, nodelist)

          neighborlist = Enum.filter(neighborlist, &(!is_nil(&1)))

          neighborlist =
            neighborlist ++ adjacentNeighbors(i, j, index_node, sqroot, totnodes, nodelist)

          neighborlist = Enum.filter(neighborlist, &(!is_nil(&1)))

          # IO.inspect(neighborlist, charlists: :as_lists)
          Project2.updateAdjList(Enum.at(nodelist,index_node), neighborlist)
        end)
    end)
  end

  # honeycomb end
end
