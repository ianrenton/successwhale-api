Set Web UI Display Settings
---------------------------

Sets the display settings that the current user uses in the web UI. Probably not useful for other clients!

The optional parameters to set are the theme (`theme`), the number of columns displayed horizontally on a screen before scrolling (`colsperscreen`) and the maximum age of items (in minutes) to draw a "this is new!" highlight box around (`highlighttime`).

* Request type: PUT
* Authentication required: yes
* Required parameters: `token`
* Optional parameters: `theme`, `colsperscreen`, `highlighttime`
* Return formats supported: JSON, XML

URL Format:

    /v3/displaysettings[.json|.xml]

Example Response (JSON):

    {
      "success":true
    }
