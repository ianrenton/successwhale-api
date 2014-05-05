Set "Post to" Accounts
----------------------

Sets the list of accounts (`posttoaccounts`) that the current user has set to post to by default in SuccessWhale. This is an array with one element for each account that the user has, with a notation (`enabled`) showing whether or not the user has chosen to post to that account when they are sending a normal status update (i.e. not a reply, retweet etc.).

The structure of `posttoaccounts` is JSON that mirrors the response from the [GET posttoaccounts](posttoaccounts-get.md) call. (XML is not supported yet.) A client can send back all the user's accounts, with the `enabled` flag set as appropriate for each one, or it can send just the ones that *are enabled* &mdash; the rest will be assumed to be disabled.

* Request type: POST
* Authentication required: yes
* Required parameters: `token`, `posttoaccounts`
* Optional parameters: none
* Return formats supported: JSON, XML

URL Format:

    /v3/posttoaccounts[.json|.xml]
    
Example `posttoaccounts` data:

      [
        {
          service: "twitter",
          username: "tsuki_chama",
          uid: "1234567890",
          enabled: true
        },
        {
          service: "facebook",
          uid: "1234567890",
          username: "Ian Renton",
          enabled: false
          }
      ]

Example Response (JSON):

    {
      "success":true
    }