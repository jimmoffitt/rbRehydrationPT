Introduction
=========

The GNIP Rehydration API lets users get full tweet content by tweet ID.  This Ruby script reads in a list of numeric
Twitter activity (tweet) IDs, and requests those activities from the Rehydration API.   Users can send batches of ID’s
to our API and we send back tweets.  The Rehydration API makes tweets available for up to 30 days.

Rehydration tweet IDs can be loaded from text files located in a user-specified "in box."  Within these files, tweet IDs
can be delimited by any non-numeric character, with commas (*.csv) and tabs (*.txt) being the most common.

Requested IDs can also be passed in with the setRequestList(array) method.

Retrieved tweets are written to a user-specified out_box, with a [tweet_id].json filename.
There is also an option to have the tweets written to a local (MySQL) database.  (See the PtDB class below for
information on what the expected local schema looks like.)

Requests for tweets can result in three results:
+ Tweet is available through API.
+ Tweet is older than what can be provided by Rehydration API.  30-days old is the anticipated limit.
+ Tweet could not be found and is not available (na).

Tweets that could not be retrieved can be handled in a flexible fashion.
+ Tweets IDs are written to an output file.
+ Also, for unavailable IDs, a file can be written in a subfolder with the API status written in it.
            
     + @out_box/@out_box_na/[tweet_id].na
     + @out_box/@out_box_out/[tweet_id].old

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


More Details
============

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



