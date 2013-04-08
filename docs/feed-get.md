Get Feed
--------

Returns a set of items (`items`) that make up the requested SuccessWhale feed. The feed can be made up of items from many individual 'source feeds' -- this is one of SuccessWhale's main selling points. For example, the feed could be a merged feed of your "mentions" from two Twitter accounts and your Facebook notifications.

You request these source feeds by supplying the `sources` parameter. This parameter consists of colon-separated feeds, each of which is a slash-separated combination of the feed source, the user id on that source that the feed belongs to, and the URL of the feed relative to the endpoint for that service. The URL component can contain extra slashes without the need for escaping. Valid sources include:

    twitter/1234567890/statuses/home_timeline
    twitter/1234567890/statuses/user_timeline
    twitter/1234567890/statuses/mentions
    twitter/1234567890/direct_messages
    twitter/1234567890/direct_messages/sent
    twitter/1234567890/user/SOMEUSER/statuses
    twitter/1234567890/lists/MYLIST/statuses
    twitter/1234567890/SOMEUSER/lists/THEIRLIST/statuses
    facebook/1234567890/me/home
    facebook/1234567890/me/feed
    facebook/1234567890/me/notifications

And for backwards-compatability with SuccessWhale v2:

    twitter/1234567890/@SOMEUSER
    twitter/1234567890/@SOMEUSER/THEIRLIST

The call also supports a `count` parameter that sets the number of items that should be returned in the feed, starting from the most recent and working backwards. You may not get exactly the requested number back, for example if you request a feed that does not have enough items in it, or when items are removed because they match a Banned Phrase. `count` is optional, the default is 20.

The `items` array that is returned contains hashes that have three components: `service` (e.g. 'twitter') so you know what to expect in the rest of the hash, `content` (a hash of all the item's parameters like the text, and who posted it), and `fetchedforuserid`. The combination of `service` and `fetchedforuserid` allows a client to identify the specific account for which the item was fetched, and later (if necessary) use SuccessWhale's Reply API to reply to it as the right user.

The components of the `content` hash vary depending on the `service`. All share a few common components, such as `text`, `id`, `time` and `links`, but there are many service-dependent ones too. For example, a tweet may be a 'retweet', in which case it will contain certain extra parameters indicating who it was retweeted by.

* Request type: GET
* Authentication required: yes
* Required parameters: `token`, `sources`
* Optional parameters: `count`
* Return formats supported: JSON, XML

URL Format:

    /v3/feed[.json|.xml]?sources=twitter/1234567890/statuses/mentions:facebook/1234567891/me/notifications&count=1

Example Response (JSON):

    {
      "success":true,
      request: [
        {
        service: "twitter",
        uid: "1234567890",
        url: "statuses/home_timeline"
        },
      ],
      "items":
      [
        {
          service: "twitter",
          fetchedforuserid: "1234567890",
          content: {
            id: 12345678901234567890,
            time: "2013-03-26T21:05:45+00:00",
            retweetedbyuser: "username",
            retweetedbyusername: "User Name",
            originalposttime: "2013-03-26T20:34:35+00:00",
            isretweet: true,
            text: "@you Here's a link to an image posted on Twitter using the Twitter app: http://t.co/1234567890 #yolo",
            fromuser: "username2",
            fromusername: "User Name 2",
            fromuseravatar: "http://blah.com/myavatarpng",
            isreply: false,
            numfavourited: null,
            numretweeted: 1,
            numreplied: null,
            inreplytostatusid: null,
            inreplytouserid: null,
            links:
            [
              {
                url: "http://t.co/1234567890",
                expanded_url: "http://twitter.com/username2/status/12345678901234567890/photo/1",
                title: "pic.twitter.com/1234567890",
                media: "http://blah.twitter.com/realpictureurl.jpg",
                indices: [94, 116]
              }
            ],
            usernames:
            [
              {
                id: 1234567890,
                user: "you",
                indices: [0, 3]
              }
            ],
            hashtags:
            [
              {
                text: "yolo",
                indices: [120, 124]
              }
            ]
          }
        },
        {
          service: "facebook",
          fetchedforuserid: "1234567891",
          content:
          {
            id: "12345678901234567890_12345678901234567890",
            type: "photo",
            time: "2013-03-26T19:34:23+00:00",
            fromuserid: "12345678901234567890",
            fromusername: "User Name",
            fromuseravatar: "http://graph.facebook.com/12345678901234567890/picture",
            numcomments: 0,
            comments: null,
            numlikes: 0,
            text: "User Name shared Bob Smith's photo.",
            links:
            [
              {
                url: "http://blah.com",
                title: "The Best Link in the World",
                preview: "http://blah.com/thumbnail.png"
              }
            ]
          }
        }
      ]
    }