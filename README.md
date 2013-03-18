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

Requirements
------------

This application requires the following gems, which can all be installed using `gem install`. They are listed with the current version numbers I am building against, although they probably work with others too.

* activesupport (3.2.12)
* builder (3.2.0)
* json (1.5.5)
* multi_json (1.6.1)
* mysql (2.9.1)
* php-serialize (1.1.0)
* rack (1.5.2)
* rack-throttle (0.3.0)
* simple_oauth (0.2.0)
* sinatra (1.3.5)
* twitter (4.6.0)
* xml-simple (1.1.2)

If you want to run within Apache, you probably also want the `passenger` gem as well.

If you are running your own copy, you will also need a mySQL server. (That's all we support at the moment, but if you'd like to fork the code and add support for something like postgres, I would love to pull it in.)  A query to populate the tables is included as `setup.sql`. (This structure will probably change in the run up to the release of SuccessWhale 3, so be prepared to migrate by hand if you store important data in the DB as it currently stands.)