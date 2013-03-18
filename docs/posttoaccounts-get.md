Get "Post to" Accounts
----------------------

Returns the list of accounts (`posttoaccounts`) that the current user has set to post to by default in SuccessWhale. This is an array with one element for each account that the user has chosen to post to when they are sending a normal status update (i.e. not a reply, retweet etc.).

* Request type: GET
* Authentication required: yes
* Required parameters: none
* Optional parameters: `sw_uid`, `secret`
* Return formats supported: JSON, XML

URL Format:

    /v3/posttoaccounts[.json|.xml]

Example Response (JSON):

    {
      "success":true,
      "posttoaccounts":
      [
        {"service":"twitter","user":"tsuki_chama"},
        {"service":"facebook","user":"Ian Renton"}
      ]
    }