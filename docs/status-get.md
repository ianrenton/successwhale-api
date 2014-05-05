Get API Server Status
---------------------

Returns status information about the SuccessWhale API. Currently limited to the version number.

* Request type: GET
* Authentication required: no
* Required parameters: none
* Optional parameters: none
* Return formats supported: JSON, XML

URL Format:

    /v3/status[.json|.xml]

Example Response (JSON):

    {
      "success": true,
      "version": 3.0.0
    }