## The brief

Our new product idea is a variant of a daily
[bullet journal](https://en.wikipedia.org/wiki/Bullet_journal).
We want to create a simple prototype for user testing.

The bullet journal app will be a web application in which users can:

- set daily goals
- a goal can be either a yes/no option (e.g. "Go for a walk every day") or a numerical option (e.g. "practice speaking French for at least 10 mins every day")
- each day, enter how well they have done against the goal
- at any time, see some simple reports of progress against goals.

### User stories

Here are some initial user stories, with
[MoSCoW](https://en.wikipedia.org/wiki/MoSCoW_method) priorities:

**M** When I am using the app<br />
I want to quickly record when I have met a current yes/no goal<br />
So that it's easy for me to check off my daily todo items.

**M** When I am using the app<br />
I want to quickly record the amount I have completed for a numerical goal<br />
So that it's easy for me to accumulate my progress each day.

**C** When I am reflecting on my progress<br />
I want to amend a previous day's daily goal results<br />
So that I can keep my progress accurate even if I forgot at the time.

**M** When I have a new goal that I want to set myself<br />
I can create a new daily target in the app<br />
So that it's easy for me to set new objectives for myself.

**S** When I am looking at reports from the app<br />
I can see my progress against recent daily goals<br />
So that I can tell if I'm succeeding at meeting my goals.

**C** When I am looking at reports from the app<br />
I can see my progress aggregated as weekly averages<br />
So that I can tell if I'm succeeding at meeting my goals.

### Keeping it simple

This is just a coding exercise. We want to keep things simple. So:

- don't worry about persistent data storage. Feel free to use a JSON file, or ephemeral storage in the app, as the data store
- don't worry about adding user authentication - assume a fixed user name or email if you need one
- feel free to create some synthetic historical data to simulate the user having used the app for a few days or weeks (otherwise the reporting feature won't be very interesting!)
- if there are interesting challenges that you anticipate but don't have time to deal with in the scope of this challenge, feel free to document next steps in a `todo.md` note.
- there's no need to deploy your solution to a platform like Vercel or Fly.io
