module Dictionary exposing (..)
import Json.Decode exposing (Decoder, string, succeed, list)
import Json.Decode.Pipeline exposing (required)


type alias Word = { word : String
  , meanings : List Meaning
  , phonetics : List Phonetic
  }

emptyWord : Word
emptyWord = 
  Word "" [] [] 

type alias Meaning = { partOfSpeech : String
  , definitions : List Definition
  }

type alias Definition = { definition : String
  }

type alias Phonetic = { text : String
  , audio : String
  }

definitionDecoder : Decoder Definition
definitionDecoder = 
  succeed Definition
    |> required "definition" string

meaningDecoder : Decoder Meaning
meaningDecoder = 
  succeed Meaning
    |> required "partOfSpeech" string
    |> required "definitions" (list definitionDecoder)
  
phoneticDecoder : Decoder Phonetic
phoneticDecoder = 
  succeed Phonetic
    |> required "text" string
    |> required "audio" string

wordDecoder : Decoder Word
wordDecoder = 
  succeed Word
    |> required "word" string
    |> required "meanings" (list meaningDecoder)
    |> required "phonetics" (list phoneticDecoder)

jsondecoder : Decoder (List Word)
jsondecoder = list wordDecoder