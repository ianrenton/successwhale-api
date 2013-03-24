Get Columns
-----------

Returns the list of columns (`columns`) that the current user has set up in SuccessWhale. This is an array with one element for each column. Each element itself consists of a sub-array (`feeds`) of one or more feeds that is pulled into that column, and also a complete 'feed path' that should be provided to the GET feed API in order to retrieve data for that colument (`feedpath`). Each feed in the `feeds` array is a hash which contains four items: the service the feed comes from (`service`) e.g. Twitter, the user ID to access that service as (`uid`), the username for the client to display when referring to that user ID (`username`), the URL of the feed relative to the base URL of the service (`url`) e.g. "statuses/home_timeline".

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
        {
          feeds: [
            {"service":"twitter",
            "uid":"1234567890",
            "username":"tsuki_chama",
            "url":"tsuki_chama/lists/soton-kiddies/statuses"}
          ],
          feedpath: "twitter/1234567890/tsuki_chama//soton-kiddies/statuses;"
        },
        {
          feeds: [
            {"service":"twitter",
            "uid":"1234567890",
            "username":"tsuki_chama",
            "url":"statuses/home_timeline"}
          ],
          feedpath: "twitter/13279532/statuses/home_timeline;"
        },
        {
          feeds: [
            {"service":"facebook",
            "uid":"1234567891",
            "username":"Ian Renton",
            "url":"me/home"},

            {"service":"twitter",
            "uid":"1234567890",
            "username":"tsuki_chama",
            "url":"statuses/mentions"},

            {"service":"facebook",
            "uid":"1234567891",
            "username":"Ian Renton",
            "url":"me/notifications"}
          ],
          feedpath: "facebook/1234567891/me/home;twitter/1234567890/statuses/mentions;facebook/1234567891/me/notifications;"
        }
      ]
    }