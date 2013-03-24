Get Accounts
------------

Returns an array of all social network accounts (`accounts`) associated with the current user.  Each one contains three or four parameters: the service (`service`) e.g. twitter, the username on that service (`username`), a unique user ID on that service (`uid`) and some kind of service-specific block authentication data (`tokens`) so that the SuccessWhale client can then authenticate itself transparently with the social network.  Note that currently we do not store a `username` for Facebook as it is not guaranteed to be unique. This may change in future.

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
          "uid":"13279532",
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
          "uid":"692175200",
          "servicetokens":"ABCDEFGHIJKLMNOPQRSTUVWXYZABCDEFGHIJKLMNOPQRSTUVWXYZ"
        }
      ]
    }