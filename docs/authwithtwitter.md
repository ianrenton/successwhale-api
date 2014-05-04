Authenticate with Twitter
-------------------------

SuccessWhale API function to authenticate a user using with Twitter.

Comes in two GET forms - one, when `callback_url` provided, which
returns the URL to visit to authorise the app. This will include the 
`callback_url` within it, so that once authenticated, the user will be
redirected back to that URL.

This callback will be a GET containing parameters called `swsessionkey`, `oauth_token`
and `oauth_verifier` which the client must pass back to this API endpoint
in order to finish the authentication and add the Twitter account to the
current user's set (if `token` is provided), or create a new SW user for 
that Twitter account (if `token` isn't provided). To do this, use the
second form of this endpoint.

### Initial Call

* Request type: GET
* Authentication required: no
* Required parameters: `callback_url`
* Optional parameters: none
* Return formats supported: JSON, XML

URL Format:

    /v3/authwithtwitter[.json|.xml]?callback_url=http://myclient.com/facebookcallback

Example Response (JSON):

    {
      "success":true,
      "url":"https://api.twitter.com/blahblahblah"
    }

### Second Call

* Request type: GET
* Authentication required: optional (provide `token` to add the Twitter account to an existing SW user, or don't provide it and a new SW user will be created)
* Required parameters: `swsessionkey`, `oauth_token`, `oauth_verifier`
* Optional parameters: `token`
* Return formats supported: JSON, XML

URL Format:

    /v3/authwithtwitter[.json|.xml]?swsessionkey=1234567890123456789012345678901234567890&oauth_token=1234567890123456789012345678901234567890&oauth_verifier=1234567890123456789012345678901234567890

Example Response (JSON):

    {
      "success":true,
      "userid":"1",
      "username":"tsuki_chama",
      "secret":"0123456789abcdef0123456789abcdef0123456789abcdef0123456789abcdef0123456789abcdef0123456789abcdef"
     }
