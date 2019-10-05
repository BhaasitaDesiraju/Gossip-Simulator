# Project 2 - Gossip Simulator

## Group Members
Ananda Bhaasita Desiraju - UFID: 40811191
Nidhi Sharma - UFID: 68431215

## Algorithms
Gossip
Push Sum

## Working Topologies
Line
Fully Connected Network
Random 2D
3D Torus
Honeycomb
Random Honeycomb

## Execution Instructions
To Compile and Build:
mix compile
mix run
mix escript.build
To Execute:
escript project2 numNodes topology algorithm

## Arguments
topology: line/full/rand2D/3Dtorus/honeycomb/randhoneycomb
algorithm: gossip/push-sum

## Observations for largest network
### Gossip
Line - 9000
Full - 10000
Random 2D -5000
3D Torus - 100000
Honeycomb - 10000
Random Honeycomb - 10000

### Push Sum
Line - 500
Full - 5000
Random 2D - 2500
3D Torus - 10000
Honeycomb - 2500
Random Honeycomb - 30000