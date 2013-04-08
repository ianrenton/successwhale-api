Get Banned Phrases
------------------

Returns the list of banned phrases (`bannedphrases`) that the current user has set up in SuccessWhale. This is an array with one element for each phrase that the user has chosen. (Setting a Banned Phrase hides all items that contain a matching phrase from the user's view. API calls such as `feed` apply the banned phrases masking automatically, but you can fetch the phrases themselves with this call so that clients can allow users to edit them.)

* Request type: GET
* Authentication required: yes
* Required parameters: `token`
* Optional parameters: none
* Return formats supported: JSON, XML

URL Format:

    /v3/bannedphrases[.json|.xml]

Example Response (JSON):

    {
      "success":true,
      "bannedphrases":
      [
        "#ff",
        "#followfriday",
        "#ww",
        "#mm",
        "#fridayreads",
        "4sq.com"
      ]
    }