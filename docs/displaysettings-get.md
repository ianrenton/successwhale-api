Get Web UI Display Settings
---------------------------

Returns the display settings that the current user uses in the web UI. Probably not useful for other clients!

The returned parameters are the theme (`theme`), the number of columns displayed horizontally on a screen before scrolling (`colsperscreen`) and the maximum age of items (in minutes) to draw a "this is new!" highlight box around (`highlighttime`).

* Request type: GET
* Authentication required: yes
* Required parameters: `token`
* Optional parameters: none
* Return formats supported: JSON, XML

URL Format:

    /v3/displaysettings[.json|.xml]

Example Response (JSON):

    {
      "success":true,
      "theme":"default",
      "colsperscreen":"4",
      "highlighttime":"15"
    }
