module Tests.Internals.TestMultiobjective where


import Test.HUnit


import Moo.GeneticAlgorithm.Types
import Moo.GeneticAlgorithm.Multiobjective.NSGA2


testMultiobjective =
    TestList
    [ "domination predicate" ~: do
        let problems = [Minimizing, Maximizing, Minimizing]
        let worst = [100, 0, 100]
        let good1 = [0, 50, 50]
        let good23 = [50, 100, 0]
        let best = [0, 100, 0]
        assertEqual "good dominates worst"
                    True (dominates problems good1 worst)
        assertEqual "good23 doesn't dominate good1"
                    False (dominates problems good23 good1)
        assertEqual "good1 doesn't dominate good23"
                    False (dominates problems good1 good23)
        assertEqual "best dominates good23"
                    True (dominates problems best good23)
        assertEqual "worst doesn't dominate best"
                    False (dominates problems worst best)
    , "calculate domination rank and dominated set" ~: do
        let genomes = [([1], [2, 2]), ([2], [3, 2]), ([3], [1,1]), ([4], [0,0::Double])]
        assertEqual "first genome"
                    (IntermediateRank {ir'dominatedBy = 2, ir'dominates = [([2],[3.0,2.0])]})
                    (rankGenome [Minimizing,Minimizing] genomes (head genomes))
        assertEqual "last genome"
                    (IntermediateRank {ir'dominatedBy = 0, ir'dominates = (take 3 genomes)})
                    (rankGenome [Minimizing,Minimizing] genomes (last genomes))
    , "non-dominated sort" ~: do
        let genomes = [ ([1], [2, 2]), ([2], [3, 2]), ([2,2], [2,3])
                      , ([3], [1,1.5]), ([3,3], [1.5, 0.5]), ([4], [0,0::Double])]
        assertEqual "non-dominated fronts"
                    [[[4]],[[3],[3,3]],[[1]],[[2],[2,2]]]
                    (map (map fst) $ nondominatedSort [Minimizing,Minimizing] genomes)
    , "calculate crowding distance" ~: do
        let inf = 1.0/0.0 :: Double
        assertEqual "two points" [inf, inf] $ crowdingDistances [[1],[2]]
        assertEqual "4 points" [inf, 2.5, inf, 2.0] $ crowdingDistances [[1.0], [2.0], [4.0], [3.5]]
        assertEqual "4 points 2D" [inf, 2.0, inf, 0.75, 2.0] $
                    crowdingDistances [[3,1], [1.75,1.75], [1,3], [2,2], [2.125,2.125]]
    , "rank with crowding" ~: do
        let gs = map (\x -> ([], x)) [[2,1],[1,2],[3,1],[1.9,1.9],[1,3]]
        let rs = rankAllSolutions [Minimizing,Minimizing] gs
        let inf = 1.0/0.0 :: Double
        assertEqual "non-dom ranks" [1,1,1,2,2]
                    (map rs'nondominationRank rs)
        assertEqual "in-front crowding distance" [inf, inf, 2.0, inf, inf]
                    (map rs'localCrowdingDistnace rs)
    , "calculate all objectives for all genomes" ~: do
        let genomes = [[8, 2], [2.0, 1.0], [1.0, 2.0], [4,4]]
        let objectives = [(Minimizing, sum), (Maximizing, product)]
                       :: [(ProblemType, [Double] -> Double)]
        let correct = [([8.0,2.0],[10.0,16.0]),([2.0,1.0],[3.0,2.0])
                      ,([1.0,2.0],[3.0,2.0]),([4.0,4.0],[8.0,16.0])]
        assertEqual "two objective functions" correct $
                    evalAllObjectives objectives genomes
    , "NSGA-II ranking with crowding" ~: do
        let correct = [3.0, 0.0, 1.0, 2.0]
        let objectives = [(Minimizing, sum), (Maximizing, product)]
                       :: [(ProblemType, [Double] -> Double)]
        assertEqual "4 solutions" correct $
                    nsga2Ranking objectives [[8,2],[2,1],[0.999,2],[4,4]]

    ]