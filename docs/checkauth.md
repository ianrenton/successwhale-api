Check Authentication Token
--------------------------

Checks to see if a given token will authenticate a user. If the returned `authenticated` parameter is `true`, the token is good and can be used in further API calls. If `authenticated` is `false`, clients can check the other flags and the error message to see what the problem was.

Note that `success` refers to whether or not the Check Auth call was successful, not whether the token authentication was successful. An invalid token, in the absence of any other problems, will result in `authenticated==false` but `success==true`.

* Request type: GET
* Authentication required: no
* Required parameters: `token`
* Optional parameters: none
* Return formats supported: JSON, XML

URL Format:

    /v3/columns[.json|.xml]

Example Response (JSON):

    {
        "success": true,
        "authenticated": false,
        "tokenexpired": false,
        "explicitfailure": true,
        "error": "A token was provided, but it did not match an entry in the database."
    }