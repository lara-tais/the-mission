# The Mission

Elixir API + JS visualizer for food truck data

## Overview

The Mission is a food truck map visualizer that will save negotiation time by suggesting a random food truck based on three simple filters:
  * Vegan: It just searches for 'vegan' in the description and menu
  * Quick: Within 1KM of the office (Coordinates for the office added to the constants file, I used ones at random for now)
  * Danger Zone: Includes trucks with lapsed or rejected permits

## Stack
  * Elixir/Phoenix API (single endpoint at this point: /api/trucks/)
  * SQLite DB: The file is included so you don't need to seed it, just run the project (Though the seeding script is included in /priv/repo/seeds.exs). Move to PostgreSQL for production.
  * Completely decoupled HTML/JS frontend: though it's served from the same project for ease of use. Access it at /
  * Leaflet.JS to graph the trucks on a map

## How to Run
  * mix deps.get
  * mix start

Enjoy!
