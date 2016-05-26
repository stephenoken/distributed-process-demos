import System.Environment (getArgs)
import System.IO
import System.Random
import Control.Monad
import Control.Distributed.Process
import Control.Distributed.Process.Node (initRemoteTable)
import Control.Distributed.Process.Backend.SimpleLocalnet
import Data.Map (Map)
import Data.Array (Array, listArray)
import qualified Data.Map as Map (fromList)

import qualified CountWords
import qualified KMeans
import qualified MonoDistrMapReduce
import qualified PolyDistrMapReduce

rtable :: RemoteTable
rtable = PolyDistrMapReduce.__remoteTable
        . MonoDistrMapReduce.__remoteTable
        . KMeans.__remoteTable
        . CountWords.__remoteTable
        $ initRemoteTable
main :: IO ()
main = do
  args <- getArgs

  case args of
    -- local word count
    "local" : "count": files -> do
      input <- constructInput files
      print $ CountWords.localCountWords input

    -- Distributed word count
    "master" : host : port : "count" : files -> do
      input <- constructInput files
      backend <- initializeBackend host port rtable
      startMaster backend $ \slave -> do
        result <- CountWords.distrCountWords slave input
        liftIO $ print result

    --Local KMeans
    "local": "kmeans": [] -> do
      points <- replicateM 50000 randomPoint
      withFile "plot.data" WriteMode $ KMeans.createGnuPlot $
        KMeans.localKMeans (arrayFromList points) (take 5 points) 5

    --Distributed KMeans
    "master" : host : port :  "kmeans" : [] -> do
      points  <- replicateM 50000 randomPoint
      backend <- initializeBackend host port rtable
      startMaster backend $ \slaves -> do
        result <- KMeans.distrKMeans (arrayFromList points) (take 5 points) slaves 5
        liftIO $ withFile "plot.data" WriteMode $ KMeans.createGnuPlot result

    -- Generic slave for distributed examples
    "slave" : host : port : [] -> do
      backend <- initializeBackend host port rtable
      startSlave backend

--------------------------------------------------------------------------------
-- Auxiliary                                                                  --
--------------------------------------------------------------------------------
constructInput :: [FilePath] -> IO (Map FilePath CountWords.Document)
constructInput files = do
  contents <- mapM readFile files
  return (Map.fromList $ zip files contents)

randomPoint :: IO KMeans.Point
randomPoint = (,) <$> randomIO <*> randomIO

arrayFromList :: [e] -> Array Int e
arrayFromList xs = listArray (0, length xs - 1) xs
