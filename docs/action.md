Perform Action
--------------

Performs a simple action on an item. Takes the ID of an item (`postid`), the service (`service`) and user ID (`uid`) to perform the action as, and a verb identifying the action (`action`).

Currently supported actions are, for tweets: 'retweet', 'favorite', 'unfavorite'. For Facebook posts and comments: 'like'.

* Request type: POST
* Authentication required: yes
* Required parameters: `service`, `uid`, `postid`, `action`
* Optional parameters: `sw_uid`, `secret`
* Return formats supported: JSON, XML

URL Format:

    /v3/action[.json|.xml]

Example Response (JSON):

    {
      "success":true
    }
