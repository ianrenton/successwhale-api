SuccessWhale API Documentation
==============================

SuccessWhale API version: 3.0.0-dev

This is a list of all the API calls supported by the SuccessWhale API, together with some supporting documentation. All URLs are relative to the API root, so if you are using the API at https://api.successwhale.com/, the URLs start there.

Each call can return JSON or XML as requested by the client. HTTP status codes are used for each response, and for clients that cannot properly handle HTTP status codes, each return structure contains a boolean `success` attribute and, if `success` is false (status codes >=300) also an `error` parameter.

Many calls are provided in a less intuitive but more compatible way, to work around the general inability of browsers to user HTTP verbs other than GET and POST when using CORS requests. Therefore we end up with `POST: /deleteaccount` rather than `DELETE /account` and so on.

Some explanation:
* [Terminology](terminology.md)
* [How does authentication work in SuccessWhale?](howto-auth.md)


Authentication
--------------

API calls:
* [Authenticate with SuccessWhale](authenticate-post.md) `POST: /v3/authenticate`
* [Authenticate with Twitter](authwithtwitter.md) `GET: /v3/authwithtwitter`
* [Authenticate with Facebook](authwithfacebook.md) `GET: /v3/authithfacebook`
* WIP: [Remove Third-party Account](deleteaccount.md) `POST: /v3/deleteaccount`
* WIP: [Create SuccessWhale Username and Password](makeswuserpass.md) `POST: /v3/makeswuserpass`
* WIP: [Remove SuccessWhale Username and Password](deleteswuserpass.md) `POST: /v3/deleteswuserpass`
* WIP: [Remove SuccessWhale Account](deleteswaccount.md) `POST: /v3/deleteswaccount`


Handling User Settings
----------------------

API calls:
* [Get Accounts](accounts-get.md) `GET: /v3/accounts`
* [Get Sources](sources.md) `GET: /v3/sources`
* [Get Columns](columns-get.md) `GET: /v3/columns`
* WIP: [Set Columns](columns-post.md) `POST: /v3/columns`
* [Get Banned Phrases](bannedphrases-get.md) `GET: /v3/bannedphrases`
* WIP: [Set Banned Phrases](bannedphrases-post.md) `POST: /v3/bannedphrases`
* [Get "Post to" Accounts](posttoaccounts-get.md) `GET: /v3/posttoaccounts`
* WIP: [Set "Post to" Accounts](posttoaccounts-post.md) `POST: /v3/posttoaccounts`
* [Get Display Settings](displaysettings-get.md) `GET: /v3/displaysettings`
* [Set Display Settings](displaysettings-post.md) `POST: /v3/displaysettings`


Social Network Interaction
--------------------------

API calls:
* [Get Feed](feed-get.md) `GET: /v3/feed`
* [Get Thread](thread-get.md) `GET: /v3/thread`
* [Post Item](item-post.md) `POST: /v3/item`
* [Delete Item](item-delete.md) `DELETE: /v3/item`
* [Perform Action](action.md) (Retweet, favorite, like...) `POST: /v3/action`


Miscellaneous
-------------

API calls:
* [Get Status](status-get.md) `GET: /v3/status`
