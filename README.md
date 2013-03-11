successwhale-api
================

API functions for the SuccessWhale Twitter and Facebook client.

Historically I have maintained that SuccessWhale is a /user/ of APIs and should not need to have one itself. However, a friend is trying to make an Android Twitter/Facebook/etc client that offers SuccessWhale's multiple columns of merged feeds -- something that, with TweetDeck gone, is not currently possible.

In order to do that I've started work on an API for SuccessWhale.

I'm writing it in Ruby (with Sinatra) to teach myself the language, so the code is probably shite right now. It will be improved once I get the hang of it!

In the future, I would like to rewrite SuccessWhale's core web UI (an ugly PHP mess) in something nicer -- Ruby, or perhaps something like backbone.js -- and make it use its own API exclusively.
