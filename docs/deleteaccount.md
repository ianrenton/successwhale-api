Delete Account
--------------

Removes a third-party service (Twitter, Facebook...) account that belongs to the current user. Takes the name of the service (`service`) and the user ID (`uid`) on that service to delete.

If this is the user's only service account and they don't have a SuccessWhale account, this is equivalent to deleting all information about them. If the user has other service accounts or has set up a SuccessWhale account, their other accounts will be unaffected.

* Request type: POST
* Authentication required: yes
* Required parameters: `token`, `service`, `uid`
* Optional parameters: none
* Return formats supported: JSON, XML

URL Format:

    /v3/deleteaccount[.json|.xml]

Example Response (JSON):

    {
      "success":true
    }
