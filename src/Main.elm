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
type Msg = Change String  | Show Bool | GenerateWord Int | GotJson (Result Http.Error (List Word)) | GotWords (Result Http.Error String)
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
      Err err -> ({model | error = "Can't get words list !", loading = False}, Cmd.none)
    GenerateWord newInt -> let newWord = grabString (Array.get (newInt) model.wordsArr) in
      ({model | toGuess = newWord}, getMeanings newWord)
    GotJson result ->
      case result of
      Ok json -> ({model | meanings = (grabWord (List.head json)).meanings, loading = False }, Cmd.none)
      Err err -> ({model | error = "Can't reach to the API !", loading = False}, Cmd.none)

  

-- SUBSCRIPTIONS
subscriptions : Model -> Sub Msg
subscriptions model = Sub.none

-- VIEW
view : Model -> Html Msg
view model =
  if model.win then
    div [id "container"][ h1 [class "text-5xl font-extrabold"][text "You got it!"] ]
  else if model.loading then
    div [id "container"][ h1 [class "text-5xl font-extrabold"][text "Loading ..."] ]
  else if (model.error /= "") then div [id "container"][ h1 [][text "Error !"] , h3 [][text model.error]]
  else
  div [id "container"] [ h1 [class "text-5xl font-extrabold"][text "Guess the word!"],
    if model.showToGuess then h2 [][text ("to guess : " ++ model.toGuess)]
    else text "",
    meaningsToHtml model.meanings,
    input [ type_ "text", placeholder "Take a guess",class "border text-sm rounded-lg focus:ring-blue-500", Html.Attributes.value model.guess, onInput Change] [],
    input [ id "show", type_ "checkbox", onClick (Show (not model.showToGuess))] [],
    label [for "show"][text "Show the answer"]
  ]
    
meaningsToHtml : List Meaning -> Html Msg
meaningsToHtml lst = ul [class "space-y-4 list-disc list-inside"] (List.map (\meaning -> li [] [h2[][text meaning.partOfSpeech], definitionsToHtml meaning.definitions]) lst)

definitionsToHtml : List Definition -> Html Msg
definitionsToHtml lst = ol [class "pl-5 mt-2 space-y-1 list-decimal list-inside"] (List.map (\def -> li [] [text def.definition]) lst)

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