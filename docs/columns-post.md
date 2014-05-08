Set Columns
-----------

Sets the columns (`columns`) that the current user uses in SuccessWhale. This is an array with one element for each column. Each element contains a single item called `sources`, which is itself an array of source hashes.

The structure of `columns` is JSON that mirrors the response from the [GET columns](columns-get.md) call. (XML is not supported yet.) A client can send back a complete set of source definitions for every source in every column, but in practice the only part that is actually required is the `fullurl` element. For example, a minimal `columns` parameter might look like this:

      [
        {
          sources: [
            {
              "fullurl":"twitter/1234567890/auser/lists/soton-kiddies/statuses"
            }
          ]
        },
        {
          sources: [
            {
              "fullurl":"twitter/1234567890/statuses/home_timeline"
            }
          ]
        },
        {
          sources: [
            {
              "fullurl":"facebook/1234567891/me/home"
            },
            {
              "fullurl":"twitter/1234567890/statuses/mentions"
            },
            {
              "fullurl":"facebook/1234567891/me/notifications"
            }
          ]
        }
      ]

All the other content that can be included by following the example of the [GET columns](columns-get.md) call &mdash; `name`, `service`, `username` for each source, `title` and `fullpath` for each column, etc. are all optional and ignored by the API.

* Request type: POST
* Authentication required: yes
* Required parameters: `token`, `columns`
* Optional parameters: none
* Return formats supported: JSON, XML

URL Format:

    /v3/columns[.json|.xml]
    
Example Response (JSON):

    {
      "success":true
    }