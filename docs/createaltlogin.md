Create Alternative Login
------------------------

Create an "alternative login" username and password. The user will then be able to use these credentials to log into SuccessWhale from locations where signing in with Twitter and Facebook are blocked.

* Request type: POST
* Authentication required: yes
* Required parameters: `token`, `username`, `password`
* Optional parameters: none
* Return formats supported: JSON, XML

URL Format:

    /v3/createaltlogin[.json|.xml]

Example Response (JSON):

    {
      "success":true
    }
