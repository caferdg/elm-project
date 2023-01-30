module Main exposing (..)
import Browser
import Html exposing (..)
import Html.Attributes exposing (..)
import Html.Events exposing (..)
import Http
import Random
import Array exposing (..)
import Dictionary exposing (..)
import Convenience exposing (..)


api : String
api = "https://api.dictionaryapi.dev/api/v2/entries/en/"

wordsPath : String
wordsPath = "static/words.txt"

-- MAIN
main : Program () Model Msg
main =
  Browser.element
    { init = init
    , update = update
    , subscriptions = subscriptions
    , view = view
    }

-- MODEL
type alias Model = { guess : String
  , toGuess : String
  , meanings : List Meaning
  , win : Bool
  , loading: Bool
  , error: String
  , showToGuess: Bool
  , wordsArr: Array String
  } 

emptyModel : Model
emptyModel = Model "" "" [] False False "" False empty

-- INIT
init : flags -> (Model, Cmd Msg)
init _ = ({emptyModel | loading = True}, getWordsList)
  

-- UPDATE
type Msg = Change String 
  | Show Bool 
  | GenerateWord Int 
  | GotJson (Result Http.Error (List Word)) 
  | GotWords (Result Http.Error String)
update : Msg -> Model -> (Model, Cmd Msg)
update msg model =
  case msg of 
    Change guess ->
      if guess == model.toGuess then ({model | win=True}, Cmd.none)
      else ({model | guess=guess}, Cmd.none)
    Show show -> ({model | showToGuess=show}, Cmd.none)
    GotWords result ->
      case result of
      Ok text -> ({model | wordsArr = (Array.fromList (String.split " " text))}, getRandomInt (Array.fromList (String.split " " text)))
      Err _ -> ({model | error = "Can't get words list. Try to run elm reactor.", loading = False}, Cmd.none)
    GenerateWord newInt -> let newWord = grabString (Array.get (newInt) model.wordsArr) in
      ({model | toGuess = newWord}, getMeanings newWord)
    GotJson result ->
      case result of
      Ok json -> ({model | meanings = (grabWord (List.head json)).meanings, loading = False }, Cmd.none)
      Err _ -> ({model | error = "Can't reach the API.", loading = False}, Cmd.none)


-- SUBSCRIPTIONS
subscriptions : Model -> Sub Msg
subscriptions _ = Sub.none

-- VIEW
view : Model -> Html Msg
view model =
  if model.win then
    div [id "container"][ h1 [][text "👏 You got it!"] ]
  else if model.loading then
    div [id "container"][ h1 [][text "🔍 Loading ..."] ]
  else if (model.error /= "") then
    div [id "container"][ h1 [class "highlight"][text "Error"] , h2 [][text model.error]]
  else
  div [id "container"] [ div[class "top"][
      h1 [][text "🔍 Guess the word"],
      if model.showToGuess then h2 [][text ("the answer was "), div[class "highlight"][text model.toGuess], text " 🙃"]
      else text ""  
    ],
    meaningsToHtml model.meanings,
    div [class "bottom"][
      input [ type_ "text", placeholder "Take a guess", Html.Attributes.value model.guess, onInput Change] [],
      label [class "wrapper"][
        input [ type_ "checkbox", onClick (Show (not model.showToGuess))] [],
        div[class "slider"][div[class "knob"][]]
      ]
    ]
  ]
    
meaningsToHtml : List Meaning -> Html Msg
meaningsToHtml lst = ul [] (List.map (\meaning -> li [] [h2[][text meaning.partOfSpeech], definitionsToHtml meaning.definitions]) lst)

definitionsToHtml : List Definition -> Html Msg
definitionsToHtml lst = ol [] (List.map (\def -> li [] [text def.definition]) lst)

getRandomInt : Array String -> Cmd Msg
getRandomInt arr = Random.generate GenerateWord (Random.int 0 ((Array.length arr)-1))

getWordsList : Cmd Msg
getWordsList = 
  Http.get
    { url = wordsPath
    , expect = Http.expectString GotWords
    }

getMeanings : String -> Cmd Msg
getMeanings word = 
  Http.get
    { url = api++word
    , expect = Http.expectJson GotJson jsondecoder
    }