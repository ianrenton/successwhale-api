SuccessWhale API Documentation
==============================

This is a list of all the API calls supported by the SuccessWhale API. All URLs are relative to the API root, so if you are using the API at http://api.successwhale.com, the URLs start there.

Most of these calls require the user to be authenticated. The exceptions are "Authenticate using [SuccessWhale|Twitter|Facebook]". For applications that accept cookies, these Authenticate calls will save a cookie with the user's ID and secret token, so that other API calls can use this information. Applications that do not accept cookies will have to supply the user ID and secret token as parameters to all subsequent calls.

Authenticate using SuccessWhale
-------------------------------

Takes a SuccessWhale username and password, and returns the user id ( `sw_uid` ) and secret token ( `secret` ) needed to access other API functions.  For clients that support cookies, this will also save a cookie file with the user id and secret, so that other API calls can be run easily.

* Request type: POST
* Authentication required: no
* Required parameters: `username`, `password`
* Optional parameters: none
* Return formats supported: JSON, XML

Note: For test purposes, a GET version of this API call is also available.  This will eventually be turned off, and if you are intending to use this code yourself I suggest you also turn it off. (The file enabling this call is `apifuncs/v3/authenticate-get.rb`.)

URL Format:

    /v3/authenticate[.json|.xml]

Example Response (JSON):

    {
      "success":true,
      "userid":"1",
      "username":"tsuki_chama",
      "secret":"0123456789abcdef0123456789abcdef0123456789abcdef0123456789abcdef0123456789abcdef0123456789abcdef"
     }


Get Accounts
------------

Returns an array of all social network accounts (`accounts`) associated with the current user.  Each one contains three or four parameters: the service (`service`) e.g. twitter, the username on that service (`username`), a unique user ID on that service (`userid`) and some kind of service-specific block authentication data (`tokens`) so that the SuccessWhale client can then authenticate itself transparently with the social network.  Note that currently we do not store a `username` for Facebook as it is not guaranteed to be unique. This may change in future.

* Request type: GET
* Authentication required: yes
* Required parameters: none
* Optional parameters: `sw_uid`, `secret`
* Return formats supported: JSON, XML

URL Format:

    /v3/accounts[.json|.xml]

Example Response (JSON):

    {
      "success":true,
      "accounts":
      [
        {
          "service":"twitter",
          "username":"tsuki_chama",
          "userid":"13279532",
          "servicetokens":
          {
            "oauth_token":"1234567890-ABCDEFGHIJKLMNOPQRSTUVWXYZABCDEF",
            "oauth_token_secret":"ABCDEFGHIJKLMNOPQRSTUVWXYZABCDEFGHIJKLM",
            "user_id":"13279532",
            "screen_name":"tsuki_chama"
          }
        },
        {
          "service":"facebook",
          "userid":"692175200",
          "servicetokens":"ABCDEFGHIJKLMNOPQRSTUVWXYZABCDEFGHIJKLMNOPQRSTUVWXYZ"
        }
      ]
    }


Get Columns
-----------

Returns the list of columns (`columns`) that the current user has set up in SuccessWhale. This is an array with one element for each column. Each element itself consists of an array of one or more feeds that is pulled into that column. Each feed is a hash which contains three items: the service the feed comes from (`service`) e.g. Twitter, the user name to access that service as (`user`), and the URL of the feed relative to the base URL of the service (`url`) e.g. "statuses/home_timeline".

* Request type: GET
* Authentication required: yes
* Required parameters: none
* Optional parameters: `sw_uid`, `secret`
* Return formats supported: JSON, XML

URL Format:

    /v3/columns[.json|.xml]

Example Response (JSON):

    {
      "success":true,
      "columns":
      [
        [
          {"service":"twitter",
          "username":"tsuki_chama",
          "url":"tsuki_chama/lists/soton-kiddies/statuses"}
        ],
        [
          {"service":"twitter",
          "username":"tsuki_chama",
          "url":"statuses/home_timeline"}
        ],
        [
          {"service":"facebook",
          "username":"Ian Renton",
          "url":"/me/home"}
        ],
        [
          {"service":"twitter",
          "username":"tsuki_chama",
          "url":"statuses/mentions"},

          {"service":"facebook",
          "username":"Ian Renton",
          "url":"notifications"}
        ]
      ]
    }


Get Feed
--------

Returns a set of items (`items`) that make up the requested SuccessWhale feed. The feed can be made up of items from many individual 'source feeds' -- this is one of SuccessWhale's main selling points. For example, the feed could be a merged feed of your "mentions" from two Twitter accounts and your Facebook notifications. You request these source feeds by supplying the `sources` parameter. This parameter should consist of an array of hashes, exactly like the output of the GET `columns` call. It must be properly `urlencode`d. The API expects this parameter to be provided in the same format that you request the result -- so if you're calling `feed.xml`, you need to provide the `sources` parameter as `urlencode`d XML, not JSON.

The `count` parameter sets the number of items that should be returned in the feed, starting from the most recent and working backwards. You may not get exactly the requested number back, for example if you request a feed that does not have enough items in it, or when items are removed because they match a Banned Phrase. `count` is optional, the default is 20.

The `items` array that is returned contains hashes that have three components: `service` (e.g. 'twitter') so you know what to expect in the rest of the hash, `content` (a hash of all the item's parameters) and `actions` (a hash of calls the user can make to act on the item).

The components of the `content` hash vary depending on the `service`. All share a few common components, such as `text`, `id`, `time` and `fromuser`, but there are many service-dependent ones too. For example, a tweet may be a 'retweet', in which case `content` will contain a `retweet` component with all the details of the _original_ tweet inside it.

* Request type: GET
* Authentication required: yes
* Required parameters: `sources`
* Optional parameters: `sw_uid`, `secret`, `count`
* Return formats supported: JSON, XML

URL Format:

    /v3/feed[.json|.xml]?sources=%5B%7B"service"%3A"twitter"%2C"username"%3A"tsuki_chama"%2C"url"%3A"statuses%2Fhome_timeline"%7D%5D&count=1

Example Response (JSON):

    {
      "success":true,
      "items":
      [
        {
          "service":"twitter",
          "content":
          {
            "text":"RT @Tri_2_Be: @Raspberry_Pi Top billing today - cover page of the E&T members magazine. Does it get any better :)) http://t.co/tqXeIXnafK",
            "id":311959518093377536,
            "time":"2013-03-13T21:58:39+00:00",
            "fromuser":"Raspberry_Pi",
            "fromusername":"Raspberry Pi"
            "fromuseravatar":"http://si0.twimg.com/profile_images/1590336143/Raspi-PGB001_normal.png",
            "isreply":false,
            "isretweet":true,
            "numfavourited":null,
            "numretweeted":5,
            "numreplied":null,
            "inreplytostatusid":null,
            "inreplytouserid":null,
            "retweet":
            {
              "text":"@Raspberry_Pi Top billing today - cover page of the E&T members magazine. Does it get any better :)) http://t.co/tqXeIXnafK",
              "id":311958235995324418,
              "time":"2013-03-13T21:53:34+00:00",
              "fromuser":"Tri_2_Be",
              "fromusername":"David Owen",
              "fromuseravatar":"http://si0.twimg.com/profile_images/2362190376/uuoh3mqtuhimtpfe3m9f_normal.jpeg",
              "isreply":false,
              "isretweet":false,
              "numfavourited":null,
              "numretweeted":5,
              "numreplied":null,
              "inreplytostatusid":null,
              "inreplytouserid":302666251
            }
          },
          "actions":
          {

          }
        }
      ]
    }



Get Banned Phrases
------------------

Returns the list of banned phrases (`bannedphrases`) that the current user has set up in SuccessWhale. This is an array with one element for each phrase that the user has chosen. (Setting a Banned Phrase hides all items that contain a matching phrase from the user's view. API calls such as `feed` apply the banned phrases masking automatically, but you can fetch the phrases themselves with this call so that clients can allow users to edit them.)

* Request type: GET
* Authentication required: yes
* Required parameters: none
* Optional parameters: `sw_uid`, `secret`
* Return formats supported: JSON, XML

URL Format:

    /v3/bannedphrases[.json|.xml]

Example Response (JSON):

    {
      "success":true,
      "bannedphrases":
      [
        "#ff",
        "#followfriday",
        "#ww",
        "#mm",
        "#fridayreads",
        "4sq.com"
      ]
    }


Get "Post to" Accounts
----------------------

Returns the list of accounts (`posttoaccounts`) that the current user has set to post to by default in SuccessWhale. This is an array with one element for each account that the user has chosen to post to when they are sending a normal status update (i.e. not a reply, retweet etc.).

* Request type: GET
* Authentication required: yes
* Required parameters: none
* Optional parameters: `sw_uid`, `secret`
* Return formats supported: JSON, XML

URL Format:

    /v3/posttoaccounts[.json|.xml]

Example Response (JSON):

    {
      "success":true,
      "posttoaccounts":
      [
        {"service":"twitter","user":"tsuki_chama"},
        {"service":"facebook","user":"Ian Renton"}
      ]
    }


Get Web UI Display Settings
---------------------------

Returns the display settings that the current user uses in the web UI. I'm not sure if this will ever be useful to a client, but I'm including it for completeness anyway. There should be no comparable POST method, as the user should be setting this stuff up in the web UI itself.

The returned parameters are the theme (`theme`), the number of columns displayed horizontally on a screen before scrolling (`colsperscreen`) and the maximum age of items (in minutes) to draw a "this is new!" highlight box around (`highlighttime`).

* Request type: GET
* Authentication required: yes
* Required parameters: none
* Optional parameters: `sw_uid`, `secret`
* Return formats supported: JSON, XML

URL Format:

    /v3/displaysettings[.json|.xml]

Example Response (JSON):

    {
      "success":true,
      "theme":"default",
      "colsperscreen":"4",
      "highlighttime":"15"
    }