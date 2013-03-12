SuccessWhale API Documentation
==============================

This is a list of all the API calls supported by the SuccessWhale API. All URLs are relative to the API root, so if you are using the API at http://api.successwhale.com, the URLs start there.

Most of these calls require the user to be authenticated. The exceptions are "Authenticate using [SuccessWhale|Twitter|Facebook]". For applications that accept cookies, these Authenticate calls will save a cookie with the user's ID and secret token, so that other API calls can use this information. Applications that do not accept cookies will have to supply the user ID and secret token as parameters to all subsequent calls.

Authenticate using SuccessWhale
-------------------------------

Takes a SuccessWhale username and password, and returns the user id (/sw_uid/) and secret token (/secret/) needed to access other API functions.  For clients that support cookies, this will also save a cookie file with the user id and secret, so that other API calls can be run easily.

* Request type: POST
* Authentication required: no
* Required parameters: /username/, /password/
* Optional parameters:
* Return formats supported: XML, JSON

URL Format:
    /v3/authenticate[.json|.xml]

List Columns
------------

Returns the list of columns (/columns/) that the current user has set up in SuccessWhale. This is an array with one element for each column. Each element consists of the "friendly name" of the column (/friendlyName/) and an array (/feeds/) of one or more feeds that is pulled into that column.

* Request type: GET
* Authentication required: yes
* Required parameters:
* Optional parameters: /sw_uid/, /secret/
* Return formats supported: XML, JSON

URL Format:
    /v3/listcolumns[.json|.xml]