SuccessWhale API Documentation
==============================

SuccessWhale API version: 3.0.0-dev

This is a list of all the API calls supported by the SuccessWhale API, together with some supporting documentation. All URLs are relative to the API root, so if you are using the API at https://api.successwhale.com/, the URLs start there.

Each call can return JSON or XML as requested by the client. HTTP status codes are used for each response, and for clients that cannot properly handle HTTP status codes, each return structure contains a boolean `success` attribute and, if `success` is false (status codes >=300) also an `error` parameter.

Authentication
--------------

Help:
* [How does authentication work in SuccessWhale?](howto-auth.md)

API calls:
* [Authenticate with SuccessWhale](authenticate-post.md) `POST: /v3/authenticate`
* WIP: [Authenticate with Twitter](authwithtwitter.md) `GET: /v3/authwithtwitter`
* WIP: [Authenticate with Facebook](authwithfacebook.md) `GET: /v3/authithfacebook`
* WIP: [Authenticate with Linkedin](authwithlinkedin.md) `GET: /v3/authwithlinkedin`
* WIP: [Remove Third-party Account](removeaccount-post.md) `POST: /v3/removeaccount`
* WIP: [Create SuccessWhale Username and Password](swuserpass-post.md) `POST: /v3/swuserpass`
* WIP: [Remove SuccessWhale Username and Password](swuserpass-delete.md) `DELETE: /v3/swuserpass`
* WIP: [Remove SuccessWhale Account](swaccount-delete.md) `DELETE: /v3/swaccount`
* WIP: [Log Out](logout-get.md) `GET: /v3/logout`


Handling User Settings
----------------------

API calls:
* [Get Accounts](accounts-get.md) `GET: /v3/accounts`
* WIP: [Set Accounts](accounts-post.md) `POST: /v3/accounts`
* [Get Columns](columns-get.md) `GET: /v3/columns`
* WIP: [Set Columns](columns-post.md) `POST: /v3/columns`
* [Get Banned Phrases](bannedphrases-get.md) `GET: /v3/bannedphrases`
* WIP: [Set Banned Phrases](bannedphrases-post.md) `POST: /v3/bannedphrases`
* [Get "Post to" Accounts](posttoaccounts-get.md) `GET: /v3/posttoaccounts`
* WIP: [Set "Post to" Accounts](posttoaccounts-post.md) `POST: /v3/posttoaccounts`
* [Get Display Settings](displaysettings-get.md) `GET: /v3/displaysettings`
* WIP: [Set Display Settings](displaysettings-post.md) `POST: /v3/displaysettings`


Social Network Interaction
--------------------------

API calls:
* [Get Feed](feed-get.md) `GET: /v3/feed`
* [Get Thread](thread-get.md) `GET: /v3/thread`
* WIP: [Get User Info](userinfo-get.md) `GET: /v3/userinfo`
* [Post Item](item-post.md) `POST: /v3/item`
* [Perform Action](action.md) (Retweet, favorite, like...) `POST: /v3/action`
* WIP: [Delete Item](item-delete.md) `DELETE: /v3/item`
