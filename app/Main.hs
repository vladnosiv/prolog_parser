module Main where

import Parser
import Text.ParserCombinators.Parsec
import System.IO
import System.Environment   
import Data.List

runParser :: Show a => String -> Parser a -> IO ()
runParser str parser  =
  case runAnyParser parser str of
    Left err -> print err
    Right r -> print r

parsePrologFromFile :: Show a => FilePath -> Parser a -> IO ()
parsePrologFromFile path parser = do
  input <- readFile path
  case runAnyParser parser input of
    Left err -> print err
    Right r -> do
      writeFile (path ++ ".out") (show r)

main :: IO()
main = do
  args <- getArgs
  let filename = (args !! 1)
  if length args < 3 then
    parsePrologFromFile filename parseProgram 
  else
    case (args !! 2) of
      "--atom" ->
          parsePrologFromFile filename parseAtom
      "--typeexpr" ->
          parsePrologFromFile filename parseType
      "--type" ->
          parsePrologFromFile filename parseTypedef
      "--module" ->
          parsePrologFromFile filename parseModule
      "--relation" ->
          parsePrologFromFile filename parseRelation
      "--list" ->
          parsePrologFromFile filename parseAtomList
      "--prog" ->
          parsePrologFromFile filename parseProgram
