Authenticate using SuccessWhale
-------------------------------

Takes a SuccessWhale username and password, and returns the user id ( `sw_uid` ) and the token ( `token` ) needed to access other API functions.  For clients that support cookies, this will also save a cookie file with the user id and secret, so that other API calls can be run easily.

* Request type: POST
* Authentication required: no
* Required parameters: `username`, `password`
* Optional parameters: none
* Return formats supported: JSON, XML

URL Format:

    /v3/authenticate[.json|.xml]

Example Response (JSON):

    {
      "success":true,
      "userid":"1",
      "username":"tsuki_chama",
      "secret":"0123456789abcdef0123456789abcdef0123456789abcdef0123456789abcdef0123456789abcdef0123456789abcdef"
     }