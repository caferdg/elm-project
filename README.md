# Guess my word 🔎
Live deployment at [caferdg.github.io/guess-my-word](https://caferdg.github.io/guess-my-word/)

## About
Website made in elm (a Haskell based purely functional language) for a school project. The goal was to make a website that would allow a user to guess a randomly chosen word. 1000 most used words are written in a txt file (`static/words.txt`) and the website choses randomly one of these words. Definitions are fetched from [Free Dictionary API](https://dictionaryapi.dev/).

## Build
`elm make src/Main.elm --optimize --output=main.js`

## Run
`elm reactor`
