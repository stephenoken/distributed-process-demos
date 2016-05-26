{-# LANGUAGE TupleSections #-}

module KMeans
    (
    Point,
    Cluster,
    localKMeans,
    createGnuPlot
    ) where

import Data.List (minimumBy)
import Data.Function (on)
import Data.Array (Array,(!), bounds)
import System.IO
import qualified Data.Map as Map (fromList, elems, toList, size)

import MapReduce

type Point = (Double,Double)
type Cluster = (Double,Double)

average :: Fractional a => [a] -> a
average xs = sum xs / fromIntegral (length xs)

distanceSq :: Point -> Point -> Double
distanceSq (x1,y1) (x2,y2) = a*a + b*b
  where
    a = x2 - x1
    b = y2 -y1

nearest :: Point -> [Cluster] -> Cluster
nearest p = minimumBy (compare `on` distanceSq p)

centre :: [Point] -> Point
centre ps = let (xs,ys) = unzip ps in (average xs, average ys)

kmeans :: Array Int Point ->  MapReduce (Int,Int) [Cluster] Cluster Point ([Point],Point)
kmeans  points  = MapReduce{
  mrMap = \(lo,hi) cs -> [let p = points ! i in (nearest p cs,p)
                         | i <- [lo..hi]
                         ],
  mrReduce = \_ ps -> (ps, centre ps)
}

localKMeans :: Array Int Point
  -> [Cluster]
  -> Int
  -> Map Cluster ([Point], Point)
localKMeans points cs iterations = go (iterations - 1)
  where
    mr :: [Cluster] -> Map Cluster ([Point],Point)
    mr = localMapReduce (kmeans points) . trivialSegmentation

    go :: Int -> Map Cluster ([Point],Point)
    go 0 = mr cs
    go n = mr . map snd . Map.elems . go $ n - 1

    trivialSegmentation :: [Cluster] -> Map (Int, Int) [Cluster]
    trivialSegmentation cs' = Map.fromList [(bounds points, cs')]

  -- | Create a gnuplot data file for the output of the k-means algorithm
  --
  -- To plot the data, use
  --
  -- > plot "<<filename>>" u 1:2:3 with points palette

createGnuPlot :: Map KMeans.Cluster ([KMeans.Point], KMeans.Point) -> Handle -> IO ()
createGnuPlot clusters h =
  mapM_ printPoint . flatten . zip colors . Map.toList $ clusters
    where
      printPoint (x, y, color) =
        hPutStrLn h $ show x ++ " " ++ show y ++ " " ++ show color

      flatten :: [(Float, (KMeans.Cluster, ([KMeans.Point], KMeans.Point)))]
              -> [(Double, Double, Float)]
      flatten = concatMap (\(color, (_, (points, _))) -> map (\(x, y) -> (x, y, color)) points)

      colors :: [Float]
      colors = [0, 1 / fromIntegral (Map.size clusters) .. 1]
