{-# LANGUAGE BangPatterns #-}
{- |

Common utility functions.

-}

module Moo.GeneticAlgorithm.Utilities
  (
  -- * Non-deterministic functions
    getRandomGenomes
  , doCrossovers
) where

import Moo.GeneticAlgorithm.Types
import Moo.GeneticAlgorithm.Random

import Control.Monad.Mersenne.Random
import Control.Monad (replicateM)

-- | Generate @n@ random genomes of length @len@ made of elements
-- in the range @(from,to)@. Return a list of genomes and a new state of
-- random number generator.
randomGenomes :: (Random a, Ord a)
              => PureMT -> Int -> Int -> (a, a) ->  ([Genome a], PureMT)
randomGenomes rng n len (from, to) =
    let lo = min from to
        hi = max from to
    in flip runRandom rng $
        replicateM n $ replicateM len $ getRandomR (lo,hi)

-- | Generate @n@ random genomes of length @len@ made of elements
-- in the range @(from,to)@. Return a list of genomes.
getRandomGenomes :: (Random a, Ord a)
                 => Int -- ^ @n@, how many genomes to generate
                 -> Int -- ^ @len@, genome length
                 ->  (a, a) -- ^ @range@ of genome bit values
                 -> Rand ([Genome a])
getRandomGenomes n len range = Rand $ \rng ->
                               let (gs, rng') = randomGenomes rng n len range
                               in  R gs rng'

-- | Take a list of parents, run crossovers, and return a list of children.
doCrossovers :: [Genome a] -> CrossoverOp a -> Rand [Genome a]
doCrossovers []      _     = return []
doCrossovers parents xover = do
  (children', parents') <- xover parents
  rest <- doCrossovers parents' xover
  return $ children' ++ rest
