Get Alternative Login Data
--------------------------

Gets information about the user's SuccessWhale alternative login username (if it exists), and for convenience a boolean flag to say whether or not it exists.

* Request type: GET
* Authentication required: yes
* Required parameters: `token`
* Optional parameters: none
* Return formats supported: JSON, XML

URL Format:

    /v3/altlogin[.json|.xml]

Example Response (JSON):

    {
      "success": true,
      "hasaltlogin": true,
      "username": "bob"
    }
