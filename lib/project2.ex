defmodule Project2 do
    use GenServer

  #Main
  def main(args) do
    numOfNodes = Enum.at(args, 0) |> String.to_integer()
    topology = Enum.at(args, 1)
    algorithm = Enum.at(args, 2)

    numOfNodes = cond do
      topology == "3Dtorus" ->
      cuberoot = trunc(:math.pow(numOfNodes, 1/3))
      numOfNodes = cuberoot * cuberoot * cuberoot
      topology == "honeycomb" || topology == "randhoneycomb" ->
      sqroot = trunc(:math.pow(numOfNodes, 1/2))
      numOfNodes = sqroot * sqroot
      true ->
      numOfNodes
    end
    nodeList = createNodes(numOfNodes)

    table = :ets.new(:table, [:named_table, :public])
    :ets.insert(table, {"convergence_count", 0})

    buildNetworkTopology(topology, nodeList)
    startTime = System.monotonic_time(:millisecond)

    startAlgo(nodeList, startTime, algorithm)
    infiniteLoop()

    # else
    #   IO.puts"Please provide input in the following format: numOfNodes topology algorithm"
    #   System.halt(1)
  end

  def createNodes(numOfNodes) do
    Enum.map((1..numOfNodes), fn(x)->
      processId = start_node()
      allotProcessId(processId, x)
      processId
    end)
  end

  #Choosing Gossip or Push sum algorithms
  def startAlgo(nodeList, startTime, algo) do
    case algo do
      "gossip" -> gossip(nodeList, startTime)
      "push-sum" -> pushSum(nodeList, startTime)
    end
  end

  #Choosing network topology
  def buildNetworkTopology(topology, nodeList) do
    case topology do
      "full" -> Topologies.fullTopology(nodeList)
      "line" -> Topologies.lineTopology(nodeList)
      "rand2D" -> Topologies.random2DTopology(nodeList)
      "3Dtorus" -> Topologies.buildtorus3D(nodeList)
      "honeycomb" -> Topologies.buildhoneycomb(nodeList)
      "randhoneycomb" -> Randhoneycomb.buildrandhoneycomb(nodeList)
    end
  end

  #Infinite loop
  def infiniteLoop() do
    infiniteLoop()
  end

  @impl true
  def init([]) do
    {:ok, {0, 0, [], 1}} #{nodeId, count, adjList, w}
  end

  #Client
  def start_node() do
    {:ok, processId} = GenServer.start_link(__MODULE__, [])
    processId
  end

  def allotProcessId(processId, nodeId) do
    GenServer.call(processId, {:AllotProcessId, nodeId})
  end

  @impl true
  def handle_call({:AllotProcessId, nodeId}, _from, state) do
    {node_id, count, adjList, w} = state
    state = {nodeId, count, adjList, w}
    {:reply, nodeId, state}
  end

#   #Gossip
  def gossip(nodeList, startTime) do
    startingNodeId = Enum.random(nodeList)
    nodeListLength = length(nodeList)
    updateRumorCount(startingNodeId, startTime, nodeListLength)
    passGossip(startingNodeId, startTime, nodeListLength)
  end

#   #Gossip - Client - Rumor count updater
  @spec updateRumorCount(atom | pid | {atom, any} | {:via, atom, any}, any, any) :: :ok
  def updateRumorCount(processId, startTime, listLength) do
    GenServer.cast(processId, {:UpdateRumorCount, startTime, listLength})
  end

  #Passing gossip
  def passGossip(startingNodeId, startTime, listLength) do
    GenServer.cast(startingNodeId, {:PassGossip, startTime, listLength})
  end

  @impl true
  def handle_cast({:PassGossip, startTime, listLength}, state) do
    {nodeId, count, adjList, w} = state
    adjNode = Enum.random(adjList)
    checkAlive = Process.alive?(adjNode)
    GenServer.cast(adjNode, {:RecurseGossip, startTime, listLength})
    if count < 10 do
      Process.send_after(self(), {:GiveTime, startTime, listLength}, 100)
    end
    {:noreply, state}
  end

  @impl true
  def handle_cast({:RecurseGossip, startTime, listLength}, state) do
    {:noreply, state} = handle_cast({:UpdateRumorCount, startTime, listLength}, state)
    {:noreply, state} = handle_cast({:PassGossip, startTime, listLength}, state)
    {:noreply, state}
  end

  @impl true
  def handle_info({:GiveTime, startTime, listLength}, state) do
    handle_cast({:PassGossip, startTime,listLength}, state)
  end

#Gossip - Server handling rumor count call
  @impl true
  def handle_cast({:UpdateRumorCount, startTime, listLength}, state) do
    {nodeId, count, adjList, w} = state

    if(count == 0) do
      convergence_count = :ets.update_counter(:table, "convergence_count", {2,1})

      if(convergence_count == listLength) do
        convergenceTime = System.monotonic_time(:millisecond) - startTime
        IO.puts("Convergence time = #{convergenceTime} ms")
        System.halt(1)
      end
    end
    state = {nodeId, count+1, adjList, w}
    {:noreply, state}
  end

  def updateAdjList(processId, adjNodes) do
    GenServer.cast(processId, {:UpdateAdjList, adjNodes})
  end

  #Server
  @impl true
  def handle_cast({:UpdateAdjList, adjNodes}, state) do
    {nodeId, count, adjList, w} = state
    state = {nodeId, count, adjNodes, w}
    {:noreply, state}
  end

  #push sum
  def pushSum(nodeList, startTime) do
    startingNodeId = Enum.random(nodeList)
    checkAlive = Process.alive?(startingNodeId)
    nodeListLength = length(nodeList)
    GenServer.cast(startingNodeId, {:ComputePushSum, 0, 0, startTime, nodeListLength})
  end

  @impl true
  def handle_cast({:ComputePushSum, s1, w1, startTime, listLength}, state) do
    {s, swCount, adjList, w} = state
    newS = s + s1
    newW = w + w1
    diff = abs(newS/newW - s/w)
    if(diff < :math.pow(10,-10) && swCount == 2) do
      convergence_count = :ets.update_counter(:table, "convergence_count", {2,1})
      if(convergence_count == listLength) do
        convergenceTime = System.monotonic_time(:millisecond) - startTime
        IO.puts("Convergence time = #{convergenceTime} ms")
        System.halt(1)
      end
    end

    count = updateSWCount(diff, swCount)
    state = {newS/2, count, adjList, newW/2}
    nextNode = Enum.random(adjList)
    GenServer.cast(nextNode, {:ComputePushSum, newS/2, newW/2, startTime, listLength})
    {:noreply, state}
  end

  def updateSWCount(diff, swCount) do
    if diff < :math.pow(10, -10) && swCount < 2 do
      swCount + 1
    else
      if(diff > :math.pow(10, -10)) do
        0
      end
    end
  end


  end
