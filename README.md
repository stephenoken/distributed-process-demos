# distributed-process-demos
Haskell Implementations

## Running Examples
- First, compile examples by running `stack build` in the root of the project
- Then call start the program doing `./.stack-work/dist--path to executable args`.
- With the distributed examples you **must run the slave first**
### Local Map Reduce (Count Words)
- Run Master/Slave `./.stack-work/dist/x86_64-osx/Cabal-1.22.5.0/build/distributed-process-simplelocalnet-mapreduce/distributed-process-simplelocalnet-mapreduce local count ./text/Somme.txt`
### Mono Distributed Map Reduce
- Run Slave `/.stack-work/dist/x86_64-osx/Cabal-1.22.5.0/build/distributed-process-simplelocalnet-mapreduce/distributed-process-simplelocalnet-mapreduce slave "127.0.0.1" 8001`
- Run Master `./.stack-work/dist/x86_64-osx/Cabal-1.22.5.0/build/distributed-process-simplelocalnet-mapreduce/distributed-process-simplelocalnet-mapreduce master localhost 8000 count ./text/Somme.txt`
### Poly Distributed Map Reduce
