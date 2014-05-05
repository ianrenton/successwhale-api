Set Banned Phrases
------------------

Sets the list of banned phrases (`bannedphrases`) that the current user wants to use in SuccessWhale. This is an array with one element for each phrase that the user has chosen, formatted as JSON. (XML is not supported yet.)

Setting a Banned Phrase hides all items that contain a matching phrase from the user's view.

* Request type: POST
* Authentication required: yes
* Required parameters: `token`, `bannedphrases`
* Optional parameters: none
* Return formats supported: JSON, XML

URL Format:

    /v3/bannedphrases[.json|.xml]

Example Response (JSON):

    {
      "success":true
    }