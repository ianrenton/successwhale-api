Delete Alternative Login
------------------------

Removes a user's "alternative login" username and password. The user's account will continue to operate normally, including logging in using Twitter and Facebook, but their alternative login credentials will no longer function.

* Request type: POST
* Authentication required: yes
* Required parameters: `token`
* Optional parameters: none
* Return formats supported: JSON, XML

URL Format:

    /v3/deletealtlogin[.json|.xml]

Example Response (JSON):

    {
      "success":true
    }
