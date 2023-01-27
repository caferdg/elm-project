module Convenience exposing (..)
import Dictionary exposing (Word)

grabString : Maybe String -> String
grabString a = 
  case a of 
    Just strin -> strin
    Nothing -> ""


grabWord : Maybe Word -> Word
grabWord a = 
  case a of 
    Just word -> word
    Nothing -> Word "" [] 

