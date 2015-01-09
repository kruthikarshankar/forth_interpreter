-------------------------------------------------------------------------
-- | Program 2,        CS 5314,        Fall 2014
--
--   Author: Kruthika Rathinavel
--   Date:   10-03-2014
--
--   Forth Mini-Interpreter in Haskell
--
--   This file is separated into two sections:
--
--     * Part I  : Helper Functions for Interpreting FORTH Programs
--
--     * Part II : interpretFORTHProgram
--
--     * Part III: Helper Functions to interpret the different FORTH operands  
--

module MiniForth where

-- ======================================================================
-- * Part I: Helper Functions for Interpreting FORTH Programs
-- ======================================================================
-- $PartI
--   This part provides generic functions to manipulate the stack, like
--   taking the required number of integers and performing the FORTH
--   operation on them.
--

-------------------------------------------------------------------------
-- | A synonym for a list of 'Int' values, intended to represent
--   a stack. 
--
type Stack = [Int]
	

-------------------------------------------------------------------------
evalStack :: (Monad m) => (a -> b -> m a) -> a -> [b] -> m a
-- ^ The evalStack function calls the given binary function, using the 
--   accumulator and the first element of the list 
--   as parameters. 
--
--   >>> evalStack interpretFORTHOperand [] ["1", "3", "5", "+"]
--   Just [8,1]
--
--   >>> evalStack interpretFORTHOperand [] ["+"]
--   Nothing
--
evalStack _ a []      =  return a
evalStack f a (x:xs)  =  do
	c <- f a x
	c `seq` evalStack f c xs
	

-------------------------------------------------------------------------	
addToM   :: (Monad m) => (a1 -> r) -> m a1 -> m r
-- ^ The liftM function takes a function and a monadic value and maps the 
--   function over the monadic value. 
--
--   >>> addToM (*3) (Just 8)
--   Just 24
--
--   >>> addToM (`mod`3) (Just 8)
--   Just 2
--
addToM f m1 = do { x1 <- m1; return (f x1) }


-- ======================================================================
-- * Part II: interpretFORTHProgram
-- ======================================================================
-- $PartII
--   This part provides the actual interpretFORTHProgram required by the 
--   assignment. 
--

-------------------------------------------------------------------------	
interpretFORTHProgram :: String -> Maybe Stack
-- ^ This function takes a single input parameter: the FORTH
--   "program" to interpret/execute. It returns a Maybe Stack that
--   is a resultant output of the FORTH program that was given as input.
--
--   >>> interpretFORTHProgram "3 4 5 6 10 +"
--   Just [16,5,4,3]
--
--   >>> interpretFORTHProgram "3 7 5 - 6 10 -"
--   Just [-4,2,3]
-- 
--   >>> interpretFORTHProgram "3 4 5 6 10 + + + + +"
--   Nothing
--
--   >>> interpretFORTHProgram "3 4 5 12 18 7 < /MOD"
--   Nothing
--
--   >>> interpretFORTHProgram "3 4 < 5 6 10 MOD DUP"
--   Just [6,6,5,-1]
--
--   >>> interpretFORTHProgram "3 4 2 < 5 6 18 7  MOD"
--   Just [4,6,5,0,3]
--
--   >>> interpretFORTHProgram "3 4 - 6 10 + -"
--   Just [-17]
--
--   >>> interpretFORTHProgram "13 4 - 6 10 *"
--   Just [60,9]
--
--   >>> interpretFORTHProgram "3 4 - 6 10 /"
--   Just [0,-1]
--
--   >>> interpretFORTHProgram "3 4 5 6 18 7 < MOD"
--   Nothing
--
--   >>> interpretFORTHProgram "13 4 - 6 10 * 5 6 7 MOD 3 5 7 /MOD = <"
--   Just [0,6,5,60,9]
--
--   >>> interpretFORTHProgram "13 4 - 6 10 * 5 6 7 MOD 3 5 7 SWAP"
--   Just [5,7,3,6,5,60,9]
--
--   >>> interpretFORTHProgram "13 4"
--   Just [4,13]
--
--   >>> interpretFORTHProgram "13 -"
--   Nothing
--
--   >>> interpretFORTHProgram "3 6 1 9 2SWAP"
--   Just [6,3,9,1]
--
--   >>> interpretFORTHProgram "3 6 1 9 2OVER"
--   Just [6,3,9,1,6,3]
--
--   >>> interpretFORTHProgram "DUP 7 7"
--   Nothing
--
--   >>> interpretFORTHProgram "3 6 2 ROT"
--   Just [3,2,6]
--
--   >>> interpretFORTHProgram "4 7 2 8 DUP OVER ROT"
--   Just [8,8,8,2,7,4]
--
--   >>> interpretFORTHProgram "4 7 2 8 DROP 2SWAP"
--   Nothing
--
--   >>> interpretFORTHProgram "4 7 OVER 2 8 8 2 DROP 2SWAP"
--   Just [2,4,8,8,7,4]
--
--   >>> interpretFORTHProgram "4 7 2 8 8 2 2DROP 2SWAP"
--   Just [7,4,8,2]
--
--   >>> interpretFORTHProgram "4 7 2 8 8 2 2OVER 2DUP"
--   Just [8,2,8,2,2,8,8,2,7,4]
--
--   >>> interpretFORTHProgram "4 7 2 8 8 2 2OVER 5 6 3 2 2DROP"
--   Just [6,5,8,2,2,8,8,2,7,4]
--   
--   >>> interpretFORTHProgram "4 7 + 2 8 - 8 -2 OVER 5 6 -3 12 2DROP"
--   Just [6,5,8,-2,8,-6,11]
--
--   >>> interpretFORTHProgram "7 + 2 8 - 8 -2 2OVER 5 6 -3 12 2DROP"
--   Nothing
--
--   >>> interpretFORTHProgram "4 7 2 DROP 8 8 2 AND 2SWAP"
--   Just [7,4,-1,8]
--
--   >>> interpretFORTHProgram "4 DUP OVER ROT"
--   Just [4,4,4]
--   
--   >>> interpretFORTHProgram "7 9 + 2 8 - 8 * -2 2OVER 5 6 DUP -3 12 2SWAP"
--   Nothing
--
--   >>> interpretFORTHProgram "3 4 5 6 10 MOD AND"
--   Just [-1,4,3]
--   
--   >>> interpretFORTHProgram "3 4 0 AND"
--   Just [0,3]
--
--   >>> interpretFORTHProgram "3 4 / 5 6 10 MOD OR AND"
--   Just [0]
--
--   >>> interpretFORTHProgram "0 0 MOD"
--   Nothing
--
--   >>> interpretFORTHProgram "0 0 /MOD"
--   Nothing
--
--   >>> interpretFORTHProgram "0 0 /"
--   Nothing
--   
--   >>> interpretFORTHProgram "3 4 0 * - 98 /"
--   Just [0]
--
--   >>> interpretFORTHProgram "3 4 0 0 OR"
--   Just [0,4,3]
--
--   >>> interpretFORTHProgram "4 7 2 DROP 8 - 8 8 2 AND 2SWAP OR"
--   Just [-1,-1,8]
--
--   >>> interpretFORTHProgram "0 0 -1 OR AND"
--   Just [0]
-- 
--   >>> interpretFORTHProgram "3 6 SWAP 1 9 0 /"
--   Nothing
--
--   >>> interpretFORTHProgram "3 6 SWAP"
--   Just [3,6]
--
--   >>> interpretFORTHProgram "3 6 7 2 2DUP"
--   Just [2,7,2,7,6,3]
--
--   >>> interpretFORTHProgram "3 6 SWAP 7 + 2 2DUP 2 DUP 4 -10 MOD -19 /MOD 8 / - 2SWAP 2OVER ROT"
--   Just [2,-6,2,2,-6,2,10,2,10,6]
--
--   >>> interpretFORTHProgram "3 6 7 2 2DUP 2 4 -10 MOD -19 /MOD 8 /"
--   Just [0,-6,2,2,7,2,7,6,3]
--   
--   >>> interpretFORTHProgram "-1 78 * 9 5 / 34 MOD 3 6 /MOD SWAP -1 OR"
--   Just [-1,0,1,-78]
--
--   >>> interpretFORTHProgram "-1 78 * 9 5 / 34 MOD 3 6 /MOD SWAP -1.0 OR AND"
--   Nothing
--   
--   >>> interpretFORTHProgram "7 9 + 2 8 - 8 * -2 61 MOD 7 /MOD"
--   Just [8,3,-48,16]
--
--   >>> interpretFORTHProgram "3 4 5 /MOD 6 10 MOD OR 6 9 AND"
--   Just [-1,-1,4,3]
--
--   >>> interpretFORTHProgram "3 DUP 44 SWAP DUP /MOD 90 Mod"
--   Nothing
--
--   >>> interpretFORTHProgram "DUP 3 4 5 /MOD 6 10 MOD OR 6 9 AND"
--   Nothing
--
--   >>> interpretFORTHProgram "4 4 = 4 5 + 5 < -"
--   Just [-1]
--
--   >>> interpretFORTHProgram "3 4 5 6 2SWAP 7 2SWAP SWAP 5 6 - / MOD /MOD"
--   Just [-3,-2,4,5]
--
--   >>> interpretFORTHProgram "3 4 = 5 0 9 + -6 2SWAP 7 2SWAP SWAP 5 6 - / MOD -8 /MOD 6 DROP 4 5 2OVER"
--   Just [0,0,5,4,0,0,7,5,9]
--
--   >>> interpretFORTHProgram "9 -1 / 3 - 34 -6 MOD -8 /MOD -11 ROT -1 MOD"
--   Just [0,-11,0,-12]
--
--   >>>  interpretFORTHProgram "0 9 2DROP"
--   Just []
--
--   >>> interpretFORTHProgram " "
--   Just []
--
--   >>> interpretFORTHProgram "-1 -0 +"
--   Just [-1]
--
interpretFORTHProgram st = evalStack interpretFORTHOperand [] (words st)


-- ======================================================================
-- * Part III: Helper Functions to interpret the different FORTH operands
-- ======================================================================
-- $PartIII
--   This part provides the necessary helper functions to evaluate every
--   FORTH operator provided in the assignment. It also has a monad 
--   version of reads function.
--   
-------------------------------------------------------------------------	
interpretFORTHOperand :: Stack -> String -> Maybe Stack
-- ^ This function takes a String, and a stack, and returns a Maybe Stack.
--   This function maps the String input argument with the FORTH operators
--   and return a Maybe Stack after performing the FORTH operation on the
--   String input and adding it to the Stack.
--
--   >>> interpretFORTHOperand [2,3,4] "+" 
--   Just [5,4]
--
--   >>> interpretFORTHOperand [] "+" 
--   Nothing
--
--   >>> interpretFORTHOperand [2,3,4,5,6] "-" 
--   Just [1,4,5,6]
--
--   >>> interpretFORTHOperand [2,4,6,8,10] "*"
--   Just [8,6,8,10]
--
--   >>> interpretFORTHOperand [1,2,3,4,5] "/"  
--   Just [2,3,4,5]
--
--   >>> interpretFORTHOperand [3,2,1] "MOD" 
--   Just [2,1]
--
--   >>> interpretFORTHOperand [3,10,4,6] "/MOD"  
--   Just [3,1,4,6]
--
--   >>> interpretFORTHOperand [3,10,4,6] "=" 
--   Just [0,4,6]
--
--   >>> interpretFORTHOperand [3,3,4,6] "=" 
--   Just [-1,4,6]
--
--   >>> interpretFORTHOperand [9,4,4,6] "<"   
--   Just [-1,4,6]
--
--   >>> interpretFORTHOperand [3,8,4,6] "<"
--   Just [0,4,6]
--
--   >>> interpretFORTHOperand [9,4,4,6] "SWAP"
--   Just [4,9,4,6]
--
--   >>> interpretFORTHOperand [9,4,4,6] "DUP"
--   Just [9,9,4,4,6]
--
--   >>> interpretFORTHOperand [9,4,4,6] "OVER"  
--   Just [4,9,4,4,6]
--
--   >>> interpretFORTHOperand [9,4,7,6] "ROT"  
--   Just [7,9,4,6]
--
--   >>> interpretFORTHOperand [9,4,7,6] "DROP" 
--   Just [4,7,6]
--
--   >>> interpretFORTHOperand [9,4,7,6,5,3] "2SWAP"  
--   Just [7,6,9,4,5,3]
--
--   >>> interpretFORTHOperand [9,4,7,6,5,3] "2DROP"  
--   Just [7,6,5,3]
--
--   >>> interpretFORTHOperand [9,4,7,6,5,3] "2DUP"   
--   Just [9,4,9,4,7,6,5,3]
--
--   >>> interpretFORTHOperand [9,4,7,6,5,3] "2OVER"
--   Just [7,6,9,4,7,6,5,3]
--
--   >>> interpretFORTHOperand [9,4,7,6,5,3] "" 
--   Nothing
--
interpretFORTHOperand (x:y:ys) "+" = return ((y + x):ys)
interpretFORTHOperand (x:y:ys) "-" = return ((y - x):ys)
interpretFORTHOperand (x:y:ys) "*" = return ((y * x):ys)
interpretFORTHOperand (x:y:ys) "/" =  if (x /= 0) then return ((y `div` x):ys) else Nothing
interpretFORTHOperand (x:y:ys) "MOD" = if (x /= 0) then return ((y `mod` x):ys) else Nothing
interpretFORTHOperand (x:y:ys) "/MOD" = if (x /= 0) then return ((y `div` x):(y `mod` x):ys) else Nothing
interpretFORTHOperand (x:y:ys) "=" = if (x==y) then return (-1:ys) else return (0:ys)
interpretFORTHOperand (x:y:ys) "<" = if (y<x) then return (-1:ys) else return (0:ys)
interpretFORTHOperand (x:y:ys) "AND" 
	| x == 0 = return (0:ys) 
	| y == 0 = return (0:ys)
    | otherwise = return (-1:ys)
interpretFORTHOperand (x:y:ys) "OR" = if (x == 0 && y == 0 ) then return (0:ys) else return (-1:ys)
interpretFORTHOperand (x:y:ys) "SWAP" = return (y:x:ys)
interpretFORTHOperand (y:ys) "DUP" = return (y:y:ys)
interpretFORTHOperand (x:y:ys) "OVER" = return (y:x:y:ys)
interpretFORTHOperand (x:y:z:ys) "ROT" = return (z:x:y:ys)
interpretFORTHOperand (y:ys) "DROP" = return (ys)
interpretFORTHOperand (x1:x2:x3:x4:xs) "2SWAP" = return (x3:x4:x1:x2:xs)
interpretFORTHOperand (x1:y1:ys) "2DUP" = return (x1:y1:x1:y1:ys)
interpretFORTHOperand (x1:x2:x3:x4:xs) "2OVER" = return (x3:x4:x1:x2:x3:x4:xs)
interpretFORTHOperand (x:y:ys) "2DROP" = return (ys)
interpretFORTHOperand xs numberStr = addToM (:xs) (readMaybe numberStr)


-------------------------------------------------------------------------	
readMaybe :: (Read a) => String -> Maybe a
-- ^ This function is a modified 'reads' function for the Monadic 
--   type, Maybe.
--
--   >>> readMaybe "2" :: Maybe Int
--   Just 2
--
--   >>> readMaybe "2SWAP" :: Maybe Int
--   Nothing
--
readMaybe st = case reads st of 
	[(x, "")] -> Just x
	_ -> Nothing

	
