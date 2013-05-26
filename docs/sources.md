Get Sources
------------

Returns an array of example sources (`sources`) that the authenticated SuccessWhale user could request a feed for, or build a column with. This is so that clients can offer a "build column" interface by blending sources offered by this call. Note that the list returned by this call is not exhaustive - it returns only the possible sources that have predictable URLs. For example, for a Twitter user it will return 'statuses/home_timeline', but not 'user/[username-matching-regex]/statuses'. This may change in future.

* Request type: GET
* Authentication required: yes
* Required parameters: `token`
* Optional parameters: none
* Return formats supported: JSON, XML

URL Format:

    /v3/sources[.json|.xml]

Example Response (JSON):

    {
        "success": true,
        "sources": [
            {
                "service": "twitter",
                "username": "joebloggs",
                "uid": "1234567890",
                "shortname": "Home Timeline",
                "fullname": "@joebloggs's Home Timeline",
                "shorturl": "statuses/home_timeline",
                "fullurl": "twitter/1234567890/statuses/home_timeline"
            },
            {
                "service": "twitter",
                "username": "joebloggs",
                "uid": "1234567890",
                "shortname": "Mentions",
                "fullname": "@joebloggs's Mentions",
                "shorturl": "statuses/mentions",
                "fullurl": "twitter/1234567890/statuses/mentions"
            },
            {
                "service": "twitter",
                "username": "fredsmith",
                "uid": "1234567891",
                "shortname": "Home Timeline",
                "fullname": "@fredsmith's Home Timeline",
                "shorturl": "statuses/home_timeline",
                "fullurl": "twitter/1234567891/statuses/home_timeline"
            },
            {
                "service": "twitter",
                "username": "fredsmith",
                "uid": "1234567891",
                "shortname": "Mentions",
                "fullname": "@fredsmith's Mentions",
                "shorturl": "statuses/mentions",
                "fullurl": "twitter/1234567891/statuses/mentions"
            }
        ]
    }