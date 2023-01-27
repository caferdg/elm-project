# Guess my word

## About
Website made in elm (a Haskell based purely functional language) for a school project. The goal was to make a website that would allow a user to guess a randomly chosen word. 1000 most used words are written a txt file (`static/words.txt`). Definitions are fetched from [Free Dictionary API](https://dictionaryapi.dev/).

## Build
`elm make src/Main.elm --optimize --output=static/main.js`

## Run
`elm reactor`
