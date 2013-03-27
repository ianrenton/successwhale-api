Authenticate with Facebook
--------------------------

This call comes in two GET forms - one, when no parameters are provided, which returns the URL that the client should point the user at in order to authorise the app on Facebook. The second form, when a `code` parameter is supplied, is used when data is being returned from Facebook via callback.

# Initial Call

* Request type: GET
* Authentication required: optional (yes for existing users adding a new Facebook account, no for first-time users starting with a Facebook account.)
* Required parameters: none
* Optional parameters: `sw_uid`, `secret`
* Return formats supported: JSON, XML

URL Format:

    /v3/authwithfacebook[.json|.xml]

Example Response (JSON):

    {
      "success":true,
      "url":"https://api.facebook.com/blahblahblah"
    }

# Callback

* Request type: GET
* Authentication required: cookie or GET authentication will be used automatically if provided in the initial call
* Required parameters: `code`
* Optional parameters: none
* Return formats supported: JSON, XML

URL Format:

    /v3/authwithfacebook[.json|.xml]?code=1234567890123456789012345678901234567890

Example Response (JSON):

    {
      "success":true,
      "userid":"1",
      "username":"tsuki_chama",
      "secret":"0123456789abcdef0123456789abcdef0123456789abcdef0123456789abcdef0123456789abcdef0123456789abcdef"
     }