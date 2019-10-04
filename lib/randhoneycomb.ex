defmodule Randhoneycomb do
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

  def randneighbor(i, j, index_node, sqroot, totnodes, nodelist) do
      [Enum.random(nodelist -- [index_node])]
  end

  def buildrandhoneycomb(nodelist) do
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

          neighborlist =
             neighborlist ++ randneighbor(i, j, index_node, sqroot, totnodes, nodelist)

          neighborlist = Enum.filter(neighborlist, &(!is_nil(&1)))

          # IO.inspect(neighborlist, charlists: :as_lists)
          Project2.updateAdjList(Enum.at(nodelist,index_node), neighborlist)
        end)
    end)
  end
end
