Delete All Data
---------------

Deletes all information SuccessWhale holds on a user &mdash; their preferences, and all the access tokens for their associated service accounts.

This is the nuclear option. An account deleted in this way cannot be recovered by any means.

SuccessWhale cannot revoke its own permissions on services' own websites, so although this will delete the access tokens for a user's Twitter account, the paranoid user may also wish to go to Twitter itself and revoke SuccessWhale's access to their account as well.

* Request type: POST
* Authentication required: yes
* Required parameters: `token`
* Optional parameters: none
* Return formats supported: JSON, XML

URL Format:

    /v3/deletealldata[.json|.xml]

Example Response (JSON):

    {
      "success":true
    }
