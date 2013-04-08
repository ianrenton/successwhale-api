Authenticate using SuccessWhale
-------------------------------

Takes a SuccessWhale username and password, and returns the token ( `token` ) needed to access other API functions.

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
      "token":"0123456789abcdef0123456789abcdef0123456789abcdef0123456789abcdef0123456789abcdef0123456789abcdef"
     }
