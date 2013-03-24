Get Feed
--------

Returns a set of items (`items`) that make up the requested SuccessWhale feed. The feed can be made up of items from many individual 'source feeds' -- this is one of SuccessWhale's main selling points. For example, the feed could be a merged feed of your "mentions" from two Twitter accounts and your Facebook notifications.

You request these source feeds by supplying the `sources` parameter. This parameter consists of colon-separated feeds, each of which is a slash-separated combination of the feed source, the user id on that source that the feed belongs to, and the URL of the feed relative to the endpoint for that service. The URL component can contain extra slashes without the need for escaping. (See the example below.)

The call also supports a `count` parameter that sets the number of items that should be returned in the feed, starting from the most recent and working backwards. You may not get exactly the requested number back, for example if you request a feed that does not have enough items in it, or when items are removed because they match a Banned Phrase. `count` is optional, the default is 20.

The `items` array that is returned contains hashes that have three components: `service` (e.g. 'twitter') so you know what to expect in the rest of the hash, `content` (a hash of all the item's parameters) and `actions` (a hash of calls the user can make to act on the item).

The components of the `content` hash vary depending on the `service`. All share a few common components, such as `text`, `id`, `time` and `fromuser`, but there are many service-dependent ones too. For example, a tweet may be a 'retweet', in which case it will contain certain extra parameters indicating who it was retweeted by.

* Request type: GET
* Authentication required: yes
* Required parameters: `sources`
* Optional parameters: `sw_uid`, `secret`, `count`
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
          "service":"twitter",
          "content":
          {
            "text":"RT @Tri_2_Be: @Raspberry_Pi Top billing today - cover page of the E&T members magazine. Does it get any better :)) http://t.co/tqXeIXnafK",
            "id":311959518093377536,
            "time":"2013-03-13T21:58:39+00:00",
            "fromuser":"Raspberry_Pi",
            "fromusername":"Raspberry Pi"
            "fromuseravatar":"http://si0.twimg.com/profile_images/1590336143/Raspi-PGB001_normal.png",
            "isreply":false,
            "isretweet":true,
            "numfavourited":null,
            "numretweeted":5,
            "numreplied":null,
            "inreplytostatusid":null,
            "inreplytouserid":null,
            "retweet":
            {
              "text":"@Raspberry_Pi Top billing today - cover page of the E&T members magazine. Does it get any better :)) http://t.co/tqXeIXnafK",
              "id":311958235995324418,
              "time":"2013-03-13T21:53:34+00:00",
              "fromuser":"Tri_2_Be",
              "fromusername":"David Owen",
              "fromuseravatar":"http://si0.twimg.com/profile_images/2362190376/uuoh3mqtuhimtpfe3m9f_normal.jpeg",
              "isreply":false,
              "isretweet":false,
              "numfavourited":null,
              "numretweeted":5,
              "numreplied":null,
              "inreplytostatusid":null,
              "inreplytouserid":302666251
            }
          },
          "actions":
          {

          }
        }
      ]
    }