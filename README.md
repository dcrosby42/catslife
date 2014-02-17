# A Cat's Life

A game by Dave and Arwen.


Go fishing.  Buy stuff.  Build a house.  You know, cat stuff!

We're starting out using the Phaser HTML5 game engine, planning to make this a web/mobile multiplayer experience at 

[Playable, as deployed on Heroku](http://catslife.heroku.com)

## Development Prereqs

You need Foreman and NodeJS installed.

    $ cd catslife
    $ foreman start

## Specs:

    $ jasmine-node spec --coffee --autotest --watch .
    # node_modules/jasmine-node/bin/jasmine-node --noStack --coffee spec/

## Deployment

    $ git push heroku master
