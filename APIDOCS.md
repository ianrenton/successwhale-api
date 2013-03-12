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
          "user":"tsuki_chama",
          "url":"tsuki_chama/lists/soton-kiddies/statuses"}
        ],
        [
          {"service":"twitter",
          "user":"tsuki_chama",
          "url":"statuses/home_timeline"}
        ],
        [
          {"service":"facebook",
          "user":"Ian Renton",
          "url":"/me/home"}
        ],
        [
          {"service":"twitter",
          "user":"tsuki_chama",
          "url":"statuses/mentions"},

          {"service":"facebook",
          "user":"Ian Renton",
          "url":"notifications"}
        ]
      ]
    }


Get Banned Phrases
------------------

Returns the list of banned phrases (`bannedphrases`) that the current user has set up in SuccessWhale. This is an array with one element for each phrase that the user has chosen. (Setting a Banned Phrase hides all items that contain a matching phrase from the user's view. API calls such as `fetchcolumn` apply the banned phrases masking automatically.)

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