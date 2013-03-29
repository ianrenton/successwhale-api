Post Item
---------

Posts an item (`text`) to one or more accounts defined by `accounts`. If no accounts are supplied, it uses the user's defaults (those that show up as enabled in the `posttoaccounts` call). (THE DEFAULT FEATURE IS NOT YET IMPLEMENTED)

* Request type: POST
* Authentication required: yes
* Required parameters: `text`
* Optional parameters: `sw_uid`, `secret`, `accounts`
* Return formats supported: JSON, XML

URL Format:

    /v3/item[.json|.xml]

Example Response (JSON):

    {
      "success":true
    }
