# Verna DailyGoals

[App screenshot](https://github.com/nicolasdabreo/verna_daily_goals/screenshot.png)

To start your Phoenix server:

  * Run `mix setup` to install and setup dependencies
  * Start Phoenix endpoint with `mix phx.server` or inside IEx with `iex -S mix phx.server`

Now you can visit [`localhost:4000`](http://localhost:4000) from your browser.

To run the tests:

  * Run `mix test`


## Initial thoughts

I'm going to write my pre-thoughts as well as any updates I have to direction here for clarity.

To begin with, the front-end task sparked more joy on initial read so I'm going for that. I'm starting to think I might prefer front-end work overall these days but I'd have been fine working on either.

I'm going to start out by adding a soft-user persona system so that we have the "idea" of users managing goals but without doing anything crazy. I think I'll also use ETS as storage seeing as its very quick to get off the ground. I might switch to DETS in order to accomodate synthetic data, that or I'll run some kind of seed function on application startup.

For these lighter style apps that utilise ETS, I often like storing state as events so I _might_ do that too here -- I probably will as the reporting feature can then support some more interesting insights.

## Update 1

After doing the walking skeleton I have decided not to store events in ETS instead preferring a more traditional system of storing the goals directly. This is due to the required work to project a current state forward as well as doing a replace on items in ets will take a while to set up and this project is not about storage.

In hindsight, using SQLite and a generator would have been quicker but I think this is a more interesting approach to show off.

## Update 2 

Now that I'm looking at adding reporting, I think shifting the data to be stored referenced to the given date rather than persona information makes the most sense. That way I can navigate on the route through dates and re-fetch the data.
