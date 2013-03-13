Successwhale API
================

This package provides API functions for the "SuccessWhale" social network client (currently supporting Twitter, Facebook and LinkedIn).

This code is under heavy development. It will form the core of the SuccessWhale version 3 web interface, and hopefully a number of other apps as well.

SuccessWhale's main selling point is that it provides customisable, blended feeds from across a user's social network accounts -- for example, you can create a feed that combines "mentions" from two of your Twitter accounts with "notifications" from Facebook.

In providing an API for SuccessWhale, I am opening this system up for others to use -- for example to build mobile apps. (Now that TweetDeck has been discontinued, very few mobile or desktop apps offer any kind of cross-service feed merging.)

The API is a Ruby application that uses the Sinatra gem for handling HTTP requests. This is my first time writing Ruby, so I'm sure there are many inefficiencies -- patches, bug reports and constructive criticism are all welcome.

For test purposes, I will host this application at http://api.successwhale.com, running on the SuccessWhale beta test (http://test.successwhale.com) database. This may not always be available, and I will almost certainly break it regularly.
