Introduction
=========

The GNIP Rehydration API lets users get full tweet content by tweet ID.  This Ruby script reads in a list of numeric
Twitter activity (tweet) IDs, and requests those activities from the Rehydration API.   Users can send batches of ID’s
to our API and we send back tweets.  The Rehydration API makes tweets available for up to 30 days.

Rehydration tweet IDs can be loaded from text files located in a user-specified "in box."  Within these files, tweet IDs
can be delimited by any non-numeric character, with commas (*.csv) and tabs (*.txt) being the most common.

Requested IDs can also be passed in with the setRequestList(array) method.

By default this script writes processed activities (tweets) as individual JSON files.  The script can also be 
configured to write activities to a local database.  There is a PtDatabase class included here that encapsulates
the database details, including an ActiveRecord schema description.  If you are using a database, the PowerTrack
configuration file must have a "database" section containing connection details.  

Requests for tweets can produce three results:
+ Tweet is available through API.
+ Tweet is older than what can be provided by Rehydration API.  30-days old is the anticipated limit.
+ Tweet could not be found and is not available (na).

Tweets that could not be retrieved can be handled in a flexible fashion.
+ Unavailable Tweets IDs are written to a list which is writtento an output file.
+ Also, for unavailable IDs, a file can be written in a subfolder with the API status written in it.
            
     + @out_box/@out_box_na/[tweet_id].na
     + @out_box/@out_box_out/[tweet_id].old

API responses include 3 key elements:
  1. The tweet ID and associated content (if available)
  2. Availability (a true/false	Boolean)
  3. Status (only present for unavailable tweets)



Usage
=====
This script is file driven.  If there are no "request id" files in the in-box to parse, this script will immediately
exit.  If there are files, this script will manage the process of making requests to the Rehydration API and writing
activity json files.

One file is passed in at the command-line if you are running this code as a script (and not building some wrapper
around the PtRehydration class):

1) A configuration file with account/username/password details and processing options (see below, or the sample project
file, for details):  -c "./PowerTrackConfig.yaml"

The PowerTrack configuration file needs to have an "account" section and a "rehydration" section.  If you specify that
you are using database (rehydration --> storage: database) you will need to have a "database" section as well.

So, if you were running from a directory with this source file in it, with the configuration file in that folder too,
the command-line would look like this:

        $ruby ./pt_rehydration.rb -c "./PowerTrackConfig.yaml"


Basics, Best Practices & Limitations
====================================

+ Authentication: Your Gnip account credentials and authentication method are the same for Rehydration as for other Gnip products.
+ Data Availability Time Window: The Rehydration API makes data available for a 
rolling window of the past 7 days (soon to be 30 days). All tweet IDs prior to 7 (30)
days ago will return a "status”:"outside available timeframe" message.
+ Request Limits: The Rehydration API has a default max limit of 100 tweet IDs per 
request, with an anticipated response time for all IDs of well under 1 second.  If an 
even lower level of response latency is desired, consider issuing requests with fewer 
than 50 IDs.
+ Rate Limit:Access to the API will be limited to a rate of 1 request per second. 
Please keep that limit in mind when deciding how many IDs to include per request.
+ Response Timeframe:Your application should support a response timeframe for a 
given request of up to 15 seconds for all individual tweets to be returned.  99+% of 
tweets will be returned in less than 1 second, but for various reasons a very small 
percentage may take longer.
+ Response Order:Individual tweets will be returned in an unordered/first-available 
list. It is important that your application allow for tweets to be processed in the 
order in which they are returned;they will not necessarily be in the order in which 
they were requested.


More Details
===========
    #TODO: add handling of requested ID with invalid formats.  

    #TODO: add a file-less mechanism for passing in IDs to Rehydration object.
    # oRehy = PtHydration.new(activity_list=nil)
    # oRehy.setActivityList(my_list)

    Loads a list of activity IDs and submits them to the Gnip Rehydration API.

    Writes individual JSON activity files: 311555594760904704.json

    Writes activities to a local folder.
    Writes activities to a local database.

    POST with JSON payload: (SUPPORTED HERE)
    https://rehydration.gnip.com:443/accounts/jim/publishers/twitter/rehydration/activities.json
    {"ids":["1","2","3"]

    GET with passed in IDs parameter: (NOT SUPPORTED HERE)
    https://rehydration.gnip.com:443/accounts/jim/publishers/twitter/rehydration/activities.json?ids=1,2,3



