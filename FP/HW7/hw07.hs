module HW07 where

class Monoid a where
    mempty :: a
    mappend :: a -> a -> a
    mconcat :: [a] -> a
    mconcat = foldr mappend mempty
    
newtype Endo a = Endo { appEndo :: a -> a }
instance Monoid (Endo a) where
    mempty = Endo id
    Endo f `mappend` Endo g = Endo (f . g)

instance Monoid a => Monoid (Maybe a) where
    mempty = Nothing
    Nothing `mappend` Nothing = Nothing
    (Just a) `mappend` Nothing = (Just a)
    Nothing `mappend` (Just b) = (Just b)
    (Just a) `mappend` (Just b) = Just (a `mappend` b)


length' :: [a] -> Int
length' = foldr (\x -> succ) 0

or' :: [Bool] -> Bool
or' = foldr1 (||)

head' :: [a] -> a
head' = foldr1 (\x y -> x)

last' :: [a] -> a
last' = foldr1 (\x y-> y)

maximum' :: (Ord a) => [a] -> a
maximum' = foldr1 max

stringConcat :: [[Char]] -> [Char]
stringConcat = foldr1 (\x y -> x ++ "," ++ y)

map' :: (a -> b) -> [a] -> [b]
map' f = foldr (\x y -> f x : y) []

filter' :: (a -> Bool) -> [a] -> [a]
filter' p = foldr f []
    where f = \x y -> case p x of
                    True -> x : y
                    otherwise -> y
                    
reverse' :: [a] -> [a]
reverse' = foldl (\x y -> y:x) [] 
-- reverse' = foldl (flip (:)) [] -- или так, но это фактически то же самое

reverse'' :: [a] -> [a]
reverse'' = foldr (\x y -> y ++ [x]) []

myfoldl :: (b -> a -> b) -> b -> [a] -> b
myfoldl f ini list = foldr (\x y -> f y x) ini (reverse list) 
-- myfoldl f ini list = foldr (\x g z -> g (f z x)) id list ini -- или так. 

-- 1. (\x g z -> g (f z x)) k id ->
-- -> \z -> id (f z k) == \z -> f z k -- функция которая принимает аргумент и возвращет действие f на этот аргумент и последний элемент списка

-- 2. (\x g z -> g (f z x)) k1 (\z -> f z k) ->
-- -> \z -> (\z' -> f z' k) (f z k1) == \z -> f (f z k1) k -- получилась функция, которая действует на предпоследний элемент, потом к результату применяем последний элемент.

-- 3. (\x g z -> g (f z x)) k2 (\z -> f (f z k1) k) ->
-- -> \z -> (\z' -> f (f z' k1) k) (f z k2) == \z -> f (f (f z k2) k1) k -- применяем к второму с конца, потом к предпоследнему, потом к послденему.

-- в итоге и получится foldl, только вместо z надо поставить исходное ini.

data Tree a = Nil | Branch (Tree a) a (Tree a)
    deriving (Eq, Show)

foldt1 :: (t -> r -> r) -> r -> Tree t -> r
foldt1 f z Nil = z
foldt1 f z (Branch l v r) = foldt1 f (f v (foldt1 f z r)) l

foldt2 :: (t -> r -> r) -> r -> Tree t -> r
foldt2 f z Nil = z
foldt2 f z (Branch l v r) = foldt2 f (f v (foldt2 f z l)) r

------------------- изменения от 19.04.2014

foldt3 :: (t -> r -> r -> r) -> r -> Tree t -> r
foldt3 f z Nil = z
foldt3 f z (Branch l v r) = f v (foldt3 f z l) (foldt3 f z r)

foldt3rev :: (t -> r -> r -> r) -> r -> Tree t -> r
foldt3rev f z Nil = z
foldt3rev f z (Branch l v r) = f v (foldt3rev f z r) (foldt3rev f z l)

getRoot :: Tree a -> [a]
getRoot Nil = []
getRoot (Branch _ v _) = [v]

getChildren :: Tree a -> [Tree a]
getChildren (Branch l v r) = [l, r]
getChildren Nil = []

bfs :: Tree a -> [a]
bfs x = bfs' [x] where
        bfs' :: [Tree a] -> [a]
        bfs' [] = []
        bfs' x = (concatMap getRoot x) ++ (bfs' $ concatMap getChildren x)

flattenTreeInOrder :: Tree t -> [t]
flattenTreeInOrder = foldt1 (:) []

flattenTreeReverseInOrder :: Tree t -> [t]
flattenTreeReverseInOrder = foldt2 (:) []

flattenTreePreOrder :: Tree t -> [t]
flattenTreePreOrder = foldt3 (\x y ys -> x : y ++ ys) []

flattenTreePostOrder :: Tree t -> [t]
flattenTreePostOrder = foldt3 (\x y ys -> y ++ ys ++ [x]) []

flattenTreeReversePreOrder :: Tree t -> [t]
flattenTreeReversePreOrder = foldt3rev (\x y ys -> x : y ++ ys) []

flattenTreeReversePostOrder :: Tree t -> [t]
flattenTreeReversePostOrder = foldt3rev (\x y ys -> y ++ ys ++ [x]) []


------------------- конец изменений от 19.04.2014

main :: IO()
main = do
    print $ foldl   (/) 480 [3, 2, 5, 2]
    print $ myfoldl (/) 480 [3, 2, 5, 2]
    
    let fn = mconcat $ map Endo [(+5),(*3),(^2)]
    print $ appEndo fn 2
    
    print $ length' "adasd"
    print $ length' [1..1000]
    
    print $ or' [False, False, False]
    print $ or' [False, False, True]
    print $ or' [False, False, True, False]
    print $ or' [False]
    print $ or' [True]

    print $ head' [2..10]
    
    print $ last' [2..10]
    
    print $ maximum' [2..10]
    print $ maximum' "defasyyouuuy"
    
    print $ stringConcat ["ab", "cde", "fgh"]
    
    print $ map  (*2) [1..10]
    print $ map' (*2) [1..10]
    
    print $ filter  (odd) [1..10]
    print $ filter' (odd) [1..10]
    
    print $ reverse' [1..10]
    print $ reverse'' [1..10]
    
    ---------------------------------
    print $ "---tree-----"
    let t1 = Branch (Branch Nil 1 Nil) 2 (Branch (Branch Nil 3 Nil) 4 (Branch Nil 5 Nil))
    print $ flattenTreeInOrder t1    
    print $ flattenTreePreOrder t1
    print $ flattenTreePostOrder t1
    print $ bfs t1    

    print $ "--- tree rev -----"    
    print $ flattenTreeReverseInOrder t1
    print $ flattenTreeReversePreOrder t1
    print $ flattenTreeReversePostOrder t1
