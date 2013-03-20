Successwhale API
================

Homepage: https://github.com/ianrenton/successwhale-api

This package provides API functions for the "SuccessWhale" social network client (currently supporting Twitter, Facebook and LinkedIn).

This code is under heavy development. It will form the core of the SuccessWhale version 3 web interface, and hopefully a number of other apps as well.

SuccessWhale's main selling point is that it provides customisable, blended feeds from across a user's social network accounts -- for example, you can create a feed that combines "mentions" from two of your Twitter accounts with "notifications" from Facebook.

In providing an API for SuccessWhale, I am opening this system up for others to use -- for example to build mobile apps. (Now that TweetDeck has been discontinued, very few mobile or desktop apps offer any kind of cross-service feed merging.)

The API is a Ruby application that uses the Sinatra gem for handling HTTP requests. This is my first time writing Ruby, so I'm sure there are many inefficiencies -- patches, bug reports and constructive criticism are all welcome.

For test purposes, I will host this application at https://api.successwhale.com, running on the SuccessWhale beta test (http://test.successwhale.com) database. This may not always be available, and I will almost certainly break it regularly.

Important Info
--------------

* [API documentation](docs/index.md) - explains how to use all the API calls
* [Licence](LICENCE.md) - BSD 2-clause licence

Installation
------------

If you want to run the SuccessWhale API on your own server, this section is for you. (Before you start, bear in mind that you can't talk to the main successwhale.com database if you run your own copy of the API code -- you'll need to bring your own database.)

First of all, install the dependencies. If you don't have ruby and ruby-gems installed on your computer, you'll have to get them first. I recommend "RVM" for managing your ruby environment.

With those installed, `git clone` this repository into a directory on your computer. `cd` into the directory. Run `gem install bundler` if necessary, then `bundle install` to install all of SuccessWhale's dependencies.

You will then need to set up a mySQL server. (That's all we support at the moment, but if you'd like to fork the code and add support for something like postgres, I would love to pull it in.)  A query to populate the tables is included as `setup.sql`. (This structure will probably change in the run up to the release of SuccessWhale 3, so be prepared to migrate by hand if you store important data in the DB as it currently stands.)