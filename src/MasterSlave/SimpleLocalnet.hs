import System.Environment (getArgs)
import System.CPUTime
import Control.Exception (evaluate)
import Control.Distributed.Process
import Control.Distributed.Process.Node(initRemoteTable)
import Control.Distributed.Process.Backend.SimpleLocalnet
import qualified MasterSlave

rtable :: RemoteTable
rtable = MasterSlave.__remoteTable initRemoteTable

main :: IO ()
main = do
  args <- getArgs

  case args of
    ["master", host, port, strN, strSpawnStrategy] -> do
      backend <- initializeBackend host port rtable
      n <- evaluate $ read strN
      spawnStrategy <- evaluate $ read strSpawnStrategy
      startMaster backend $ \slaves -> do
        time0 <- liftIO getCPUTime
        result <- MasterSlave.master n spawnStrategy slaves
        time1 <- liftIO getCPUTime
        liftIO $ print result
        liftIO $ print ("CPU time for process: " ++show(fromIntegral(time1-time0) / 1.0e12))
    ["slave", host,port] -> do
      backend <- initializeBackend host port rtable
      startSlave backend 
