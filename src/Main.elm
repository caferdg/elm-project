module Main exposing (..)
import Browser
import Html exposing (..)
import Html.Attributes exposing (..)
import Html.Events exposing (..)
import Http
import Random

--MAIN
main : Program () Model Msg
main =
  Browser.element
    { init = init
    , update = update
    , subscriptions = subscriptions
    , view = view
    }


-- MODEL
type Model = Win | Waiting String

--INIT
init : flags -> (Model, Cmd Msg)
init _ =
  (Waiting "", Cmd.none)
  

-- UPDATE
type Msg
 = Change String

update : Msg -> Model -> (Model, Cmd Msg)
update msg model =
  case msg of
    Change guess -> case guess of
      "theWordToGuess" -> (Win, Cmd.none)
      _ -> (Waiting guess, Cmd.none)


-- SUBSCRIPTIONS
subscriptions : Model -> Sub Msg
subscriptions model =
  Sub.none

-- VIEW
view : Model -> Html Msg
view model =
  case model of
    Win ->
      h1 [][text "Win"]
    Waiting guess ->
      div []
      [ h1 [][text "Guess the word!"],
        input [ placeholder "Take a guess", value guess, onInput Change] []
      ]
      