Get "Post to" Accounts
----------------------

Returns the list of accounts (`posttoaccounts`) that the current user has set to post to by default in SuccessWhale. This is an array with one element for each account that the user has, with a notation (`enabled`) showing whether or not the user has chosen to post to that account when they are sending a normal status update (i.e. not a reply, retweet etc.).

When replying, retweeting etc., clients should normally perform the action as the user for whom the item was returned (e.g. if the item comes from user1's home timeline, the default is to reply as user1.)  Clients may force this, or give the user a choice with the 'normal' one selected as default.

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
        {
          service: "twitter",
          username: "tsuki_chama",
          uid: "1234567890",
          enabled: true
        },
        {
          service: "facebook",
          uid: "1234567890",
          enabled: false
          }
      ]
    }