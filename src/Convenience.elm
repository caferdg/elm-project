module Convenience exposing (..)
import Dictionary exposing (Word, Phonetic, emptyWord)

grabString : Maybe String -> String
grabString a = 
  case a of 
    Just strin -> strin
    Nothing -> ""

grabWord : Maybe Word -> Word
grabWord a = 
  case a of 
    Just word -> word
    Nothing -> emptyWord

grabPhon : Maybe Phonetic -> Phonetic
grabPhon a = 
  case a of 
    Just phon -> phon
    Nothing -> Phonetic "" ""

getAudio : List Phonetic -> String
getAudio phonetics = 
  case phonetics of 
    [] -> ""
    phonetic :: rest -> 
      if phonetic.audio == "" then 
        getAudio rest
      else 
        phonetic.audio

