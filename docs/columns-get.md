Get Columns
-----------

Returns the list of columns (`columns`) that the current user has set up in SuccessWhale. This is an array with one element for each column. Each element itself consists of an array of one or more feeds that is pulled into that column. Each feed is a hash which contains four items: the service the feed comes from (`service`) e.g. Twitter, the user ID to access that service as (`uid`), the username for the client to display when referring to that user ID (`username`) and the URL of the feed relative to the base URL of the service (`url`) e.g. "statuses/home_timeline".

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
          "uid":"1234567890",
          "username":"tsuki_chama",
          "url":"tsuki_chama/lists/soton-kiddies/statuses"}
        ],
        [
          {"service":"twitter",
          "uid":"1234567890",
          "username":"tsuki_chama",
          "url":"statuses/home_timeline"}
        ],
        [
          {"service":"facebook",
          "uid":"1234567891",
          "username":"Ian Renton",
          "url":"/me/home"}
        ],
        [
          {"service":"twitter",
          "uid":"1234567890",
          "username":"tsuki_chama",
          "url":"statuses/mentions"},

          {"service":"facebook",
          "uid":"1234567891",
          "username":"Ian Renton",
          "url":"notifications"}
        ]
      ]
    }