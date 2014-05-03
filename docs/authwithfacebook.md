Authenticate with Facebook
--------------------------

SuccessWhale API function to authenticate a user using with Facebook.

Comes in two GET forms - one, when `callback_url` provided, which
returns the URL to visit to authorise the app. This will include the 
`callback_url` within it, so that once authenticated, the user will be
redirected back to that URL.

This callback will be a GET containing a parameter called `code` which
the client must pass back to this API endpoint in order to finish the
authentication and add the Facebook account to the current user's set
(if `token` is provided), or create a new SW user for that Facebook
account (if `token` isn't provided). To do this, use the
second form of this endpoint, where `code` is provided. To verify that
it's the same client communicating, it must provide the same value
of `callback_url` to this call too. 

### Initial Call

* Request type: GET
* Authentication required: no
* Required parameters: `callback_url`
* Optional parameters: none
* Return formats supported: JSON, XML

URL Format:

    /v3/authwithfacebook[.json|.xml]?callback_url=http://myclient.com/facebookcallback

Example Response (JSON):

    {
      "success":true,
      "url":"https://www.facebook.com/blahblahblah"
    }

### Second Call

* Request type: GET
* Authentication required: optional (provide `token` to add the Facebook account to an existing SW user, or don't provide it and a new SW user will be created)
* Required parameters: `code`, `callback_url`
* Optional parameters: `token`
* Return formats supported: JSON, XML

URL Format:

    /v3/authwithfacebook[.json|.xml]?code=1234567890123456789012345678901234567890&callback_url=http://myclient.com/facebookcallback

Example Response (JSON):

    {
      "success":true,
      "userid":"1",
      "username":"tsuki_chama",
      "secret":"0123456789abcdef0123456789abcdef0123456789abcdef0123456789abcdef0123456789abcdef0123456789abcdef"
     }
