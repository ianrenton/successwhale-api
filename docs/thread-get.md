Get Thread
----------

Returns a set of items (`items`) that make up a thread based around the requested item.

You request these threads by supplying three parameters. `postid` gives the API the ID of the post (status, tweet...) you want to get a thread from. `service` (e.g. `twitter`) tells the API which service to go to to fetch an item with that ID. And `uid` tells SuccessWhale which user on that service to authenticate as, in case the item you're fetching is not public.

The `items` array that is returned varies depending on the `service` used. If you request the thread for a tweet, it grabs that tweet and walks the replyTo chain until it reaches the top, returning all tweets newest-first. If you request the thread for a Facebook post, it returns that post as the first item in the `items` array, followed by subsequent items representing its comments.

The optional `skipfirst` parameter will prevent the API from returning the first item in the sequence -- i.e. the item for which the feed was originally requested. This helps reduce the amount of data that clients need to request if they have the first item cached already.

* Request type: GET
* Authentication required: yes
* Required parameters: `token`, `service`, `uid`, `postid`
* Optional parameters: `skipfirst`
* Return formats supported: JSON, XML

URL Format:

    /v3/thread[.json|.xml]?service=facebook&uid=1234567890&postid=1234567890_12345678901234567

Example Response for Facebook (JSON):

    {
      "success":true,
      "items":
      [
        {
          service: "facebook",
          fetchedforuserid: "1234567890",
          content: {
            id: "1234567890_12345678901234567",
            type: "facebook_status",
            time: "2013-03-28T21:01:51+00:00",
            fromuserid: "1234567891",
            fromusername: "John Doe",
            fromuseravatar: "http://graph.facebook.com/1234567891/picture",
            numcomments: 1,
            numlikes: 0,
            text: "A status!"
          }
        },
        {
            "service": "facebook",
            "fetchedforuserid": "1234567890",
            "content": {
                "type": "facebook_comment",
                "id": "1234567890_12345678901234567_123456",
                "time": "2013-04-08T21:50:33+01:00",
                "fromuserid": "1234567892",
                "fromusername": "Jane Doe",
                "fromuseravatar": "http://graph.facebook.com/1234567892/picture",
                "text": "lol #yolo #swag"
            }
        }
      ]
    }

Example Response for Twitter (JSON):

    {
      "success":true,
      "items":
      [
        {
          service: "twitter",
          fetchedforuserid: "1234567890",
          content:
          {
            text: "@bobsmith Reply!",
            type: "tweet",
            id: "12345678901234567891",
            time: "2013-03-28T22:45:30+00:00",
            fromuser: "joebloggs",
            fromusername: "Joe Bloggs",
            fromuseravatar: "http://si0.twimg.com/profile_images/blah.gif",
            isreply: true,
            isretweet: false,
            numfavourited: null,
            numretweeted: 1,
            numreplied: null,
            inreplytostatusid: "12345678901234567890",
            inreplytouserid: 1234567891,
            links: [ ],
            usernames: [ ],
            hashtags: [ ]
          }
        },
        {
          service: "twitter",
          fetchedforuserid: "1234567890",
          content:
          {
            text: "Post!",
            id: "12345678901234567890",
            time: "2013-03-28T22:39:35+00:00",
            fromuser: "bobsmith",
            fromusername: "Bob Smith",
            fromuseravatar: "http://si0.twimg.com/profile_images/blah.png",
            isreply: false,
            isretweet: false,
            numfavourited: null,
            numretweeted: 1,
            numreplied: null,
            inreplytostatusid: null,
            inreplytouserid: null,
            links: [ ],
            usernames: [ ],
            hashtags: [ ]
          }
        }
      ]
    }
