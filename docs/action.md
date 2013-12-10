Perform Action
--------------

Performs a simple action on an item. Takes the ID of an item (`postid`), the service (`service`) and user ID (`uid`) to perform the action as, and a verb identifying the action (`action`).

Currently supported actions are, for tweets: 'retweet', 'favorite', 'unfavorite', 'delete'. For Facebook posts and comments: 'like', 'unlike', 'delete'.

When deleting items, the `DELETE /item` call is preferred, but as web-based clients have issues with CORS when using the DELETE type, deletion is provided here as an action as well. 

* Request type: POST
* Authentication required: yes
* Required parameters: `token`, `service`, `uid`, `postid`, `action`
* Optional parameters: none
* Return formats supported: JSON, XML

URL Format:

    /v3/action[.json|.xml]

Example Response (JSON):

    {
      "success":true
    }
