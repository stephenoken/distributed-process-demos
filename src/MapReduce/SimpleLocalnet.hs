import System.Environment(getArgs)
-- import System.IO
-- import Control.Applicative
-- import Control.Monad
import Data.Map as Map



import CountWords
-- import MapReduce
main :: IO ()
main = do
  args <- getArgs

  case args of
    "local" : "count": files -> do
      input <- constructInput files
      print $ CountWords.localCountWords input

--------------------------------------------------------------------------------
-- Auxiliary                                                                  --
--------------------------------------------------------------------------------
constructInput :: [FilePath] -> IO (Map FilePath CountWords.Document)
constructInput files = do
  contents <- mapM readFile files
  return (Map.fromList $ zip files contents)
