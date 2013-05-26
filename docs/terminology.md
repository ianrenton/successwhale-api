Terminology used by SuccessWhale
================================

This file attempts to explain the terminology used in the SuccessWhale API. I am aware that this is pretty complex at the moment, and if anyone is willing to come up with some better names and concepts here, I'm very happy to include their changes.

Some of the terms you will encounter when dealing with the SuccessWhale API are:

* **Service** refers to a social network for which SuccessWhale is a client, for example Twitter or Facebook.
* **Account** refers to a user's account on a _service_, for which authentication tokens are stored by SuccessWhale. So for example, "@joebloggs" is an _account_ on the Twitter _service_.
* **SuccessWhale Account** refers to a user's account on SuccessWhale, which acts as an interface to all their other registered _accounts_. A user's _SuccessWhale account_ is identified by a _SuccessWhale token_ which _API clients_ use to request things from the SuccessWhale API. Users can also create a username and password for their _SuccessWhale account_, which allows them to log in to SuccessWhale directly. This is entirely optional, and mainly useful for users on networks where the _service_ websites are blocked by firewalls but SuccessWhale is not.
* **SuccessWhale token** is the alphanumeric string that the SuccessWhale API returns after a successful authentication. _API clients_ provide this token as a parameter to future API calls where authentication is required.
* **API clients** are applications that talk to the SuccessWhale API. Examples include the SuccessWhale web interface, and the Android app OnoSendai. SuccessWhale _API clients_ may also be clients of _services_ in their own right.
* **Source** refers to a particular feed from a particular _account_. For example, @joebloggs' "Home Timeline" is a _source_.
* **Column** refers to a set of _sources_ that are blended into a single _feed_, in a manner configured by the user. For example, a _column_ might include the "Home Timeline" from a Twitter _account_ and the "Home Feed" from a Facebook _account_. A _column_ does not imply any actual data, just the configuration of one or more _sources_.
* **Feed** refers to the data retrieved for a _column_. A feed consists of many _items_ which can have come from any of the _sources_ that were blended to make that _column_.
* **Item** refers to the basic 'status update' element on any _service_. A tweet is an _item_, as is a Facebook post, a comment, a notification, and a direct message.
* **Thread** refers to a _feed_ that belongs not to a _column_ but to an individual _item_. The _thread_ for a tweet will include all the tweets in the reply chain, while a _thread_ for a Facebook post will include all its comments.
* **Action** refers to anything you can do with an _item_ apart from posting it, replying to it or deleting it. Possible _actions_ include retweeting, liking, and favouriting.
* **Banned Phrases** are strings that the user does not want to see in their _feeds_. Any _item_ containing text that matches a _banned phrase_ will be hidden from _feeds_. (They will still be shown in _threads_ so as to preserve the flow of conversation.)
* **'Post to' Accounts** are the accounts which new _items_ will be sent to. For example, users may not wish to post a new _item_ to all their accounts, just a select few. This can be set by the user on an item-by-item basis, and SuccessWhale also maintains a record of the user's default setting.
