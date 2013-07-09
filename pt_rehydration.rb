#!/usr/bin/env ruby

=begin

Introduction
==============

The GNIP Rehydration API lets users get full tweet content by tweet ID.  This Ruby script reads in a list of numeric
Twitter activity (tweet) IDs, and requests those activities from the Rehydration API.   Users can send batches of ID’s
to our API and we send back tweets.  The Rehydration API makes tweets available for up to 30 days.

Rehydration tweet IDs can be loaded from text files located in a user-specified "in box."  Within these files, tweet IDs
can be delimited by any non-numeric character, with commas (*.csv) and tabs (*.txt) being the most common.

Requested IDs can also be passed in with the setRequestList(array) method.

Retrieved tweets are written to a user-specified out_box, with a [tweet_id].json filename.
There is also an option to have the tweets written to a local (MySQL) database.  (See the PtDB class below for
information on what the expected local schema looks like.)

Requests for tweets can result in four results:
+ Tweet is available through API.
+ Tweet is older than what can be provided by Rehydration API.  30-days old is the anticipated limit.
+ Tweet could not be found and is not available (na).
+ Tweet ID format is invalid.  IDs must be numeric and have no more than 18 digits.

Tweets that could not be retrieved can be handled in a flexible fashion.
+ Tweets IDs are written to an output file.
+ Also, for unavailable IDs, a file can be written in a subfolder with the API status written in it.
            @out_box/@out_box_na/[tweet_id].na
            @out_box/@out_box_out/[tweet_id].old

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

    Writes two other files with information on tweets that were not available:
        tweet_ids_not_found_YYYY_MM_DD_hh_mm_ss.csv
        tweet_ids_too_old_YYYY_MM_DD_hh_mm_ss.csv

    Writes activities to a local folder.
    Writes activities to a local database.

    POST with JSON payload: (SUPPORTED HERE)
    https://rehydration.gnip.com:443/accounts/jim/publishers/twitter/rehydration/activities.json
    {"ids":["1","2","3"]

    GET with passed in IDs parameter: (NOT SUPPORTED HERE)
    https://rehydration.gnip.com:443/accounts/jim/publishers/twitter/rehydration/activities.json?ids=1,2,3


Example API responses:

        All IDs available:
        ["[{\"content\":{\"id\":\"tag:search.twitter.com,2005:311544126862680065\",\"objectType\":\"activity\",\"actor\":{\"objectType\":\"person\",\"id\":\"id:twitter.com:18092217\",\"link\":\"http://www.twitter.com/Chef_Jay\",\"displayName\":\"Chef Jay\",\"postedTime\":\"2008-12-13T02:52:53.000Z\",\"image\":\"http://a0.twimg.com/profile_images/118648879/Recolor_Sushi_normal.JPG\",\"summary\":\"Extreme Cuisine Marketing Wiz, Catering Chef, Sushi Evangelist, Restaurant Consultant, and Mobile Marketer! Former entertainment ad man\",\"links\":[{\"href\":\"http://www.jayeats.com\",\"rel\":\"me\"}],\"friendsCount\":10495,\"followersCount\":11368,\"listedCount\":538,\"statusesCount\":45103,\"twitterTimeZone\":\"Pacific Time (US & Canada)\",\"verified\":false,\"utcOffset\":\"-28800\",\"preferredUsername\":\"Chef_Jay\",\"languages\":[\"en\"],\"location\":{\"objectType\":\"place\",\"displayName\":\"Los Angeles and Honolulu\"}},\"verb\":\"post\",\"postedTime\":\"2013-03-12T18:28:02.000Z\",\"generator\":{\"displayName\":\"SharedBy\",\"link\":\"http://www.sharedby.co\"},\"provider\":{\"objectType\":\"service\",\"displayName\":\"Twitter\",\"link\":\"http://www.twitter.com\"},\"link\":\"http://twitter.com/Chef_Jay/statuses/311544126862680065\",\"body\":\"Eating brisket, ribs and sausage at Snow's BBQ in Lexington, TX http://t.co/5NZJmygM17 #texas #bbq #brisket #ribs #sausage\",\"object\":{\"objectType\":\"note\",\"id\":\"object:search.twitter.com,2005:311544126862680065\",\"summary\":\"Eating brisket, ribs and sausage at Snow's BBQ in Lexington, TX http://t.co/5NZJmygM17 #texas #bbq #brisket #ribs #sausage\",\"link\":\"http://twitter.com/Chef_Jay/statuses/311544126862680065\",\"postedTime\":\"2013-03-12T18:28:02.000Z\"},\"twitter_entities\":{\"hashtags\":[{\"text\":\"texas\",\"indices\":[87,93]},{\"text\":\"bbq\",\"indices\":[94,98]},{\"text\":\"brisket\",\"indices\":[99,107]},{\"text\":\"ribs\",\"indices\":[108,113]},{\"text\":\"sausage\",\"indices\":[114,122]}],\"urls\":[{\"url\":\"http://t.co/5NZJmygM17\",\"expanded_url\":\"http://shrd.by/3COONa\",\"display_url\":\"shrd.by/3COONa\",\"indices\":[64,86]}],\"user_mentions\":[]},\"twitter_filter_level\":\"medium\",\"retweetCount\":0},\"id\":\"311544126862680065\",\"available\":true},
           {\"content\":{\"id\":\"tag:search.twitter.com,2005:311544127449886721\",\"objectType\":\"activity\",\"actor\":{\"objectType\":\"person\",\"id\":\"id:twitter.com:634042947\",\"link\":\"http://www.twitter.com/mycluelessheart\",\"displayName\":\"mycluelessheart\",\"postedTime\":\"2012-07-12T18:58:17.000Z\",\"image\":\"http://a0.twimg.com/profile_images/2895988445/4009940d017b26ccb1856e468549ac1d_normal.png\",\"summary\":\"ashrald fanatic. Twitter monster\",\"links\":[{\"href\":null,\"rel\":\"me\"}],\"friendsCount\":56,\"followersCount\":140,\"listedCount\":0,\"statusesCount\":2069,\"twitterTimeZone\":\"Arizona\",\"verified\":false,\"utcOffset\":\"-25200\",\"preferredUsername\":\"mycluelessheart\",\"languages\":[\"en\"],\"location\":{\"objectType\":\"place\",\"displayName\":\"los angeles\"}},\"verb\":\"post\",\"postedTime\":\"2013-03-12T18:28:02.000Z\",\"generator\":{\"displayName\":\"Twitter for iPhone\",\"link\":\"http://twitter.com/download/iphone\"},\"provider\":{\"objectType\":\"service\",\"displayName\":\"Twitter\",\"link\":\"http://www.twitter.com\"},\"link\":\"http://twitter.com/mycluelessheart/statuses/311544127449886721\",\"body\":\"@SaGeSprightly @rockofsolace waaaaaah ...parang mas feel ko ang\\\"it will rain\\\"\",\"object\":{\"objectType\":\"note\",\"id\":\"object:search.twitter.com,2005:311544127449886721\",\"summary\":\"@SaGeSprightly @rockofsolace waaaaaah ...parang mas feel ko ang\\\"it will rain\\\"\",\"link\":\"http://twitter.com/mycluelessheart/statuses/311544127449886721\",\"postedTime\":\"2013-03-12T18:28:02.000Z\"},\"inReplyTo\":{\"link\":\"http://twitter.com/SaGeSprightly/statuses/311542993859526656\"},\"twitter_entities\":{\"hashtags\":[],\"urls\":[],\"user_mentions\":[{\"screen_name\":\"SaGeSprightly\",\"name\":\"JOY\",\"id\":891617934,\"id_str\":\"891617934\",\"indices\":[0,14]},{\"screen_name\":\"rockofsolace\",\"name\":\"Sasa\xE2\x99\xA5Gege fan\",\"id\":804097502,\"id_str\":\"804097502\",\"indices\":[15,28]}]},\"twitter_filter_level\":\"medium\",\"retweetCount\":0},\"id\":\"311544127449886721\",\"available\":true},
           {\"content\":{\"id\":\"tag:search.twitter.com,2005:311544126913015809\",\"objectType\":\"activity\",\"actor\":{\"objectType\":\"person\",\"id\":\"id:twitter.com:709656714\",\"link\":\"http://www.twitter.com/SalletLucas\",\"displayName\":\"sallet lucas\",\"postedTime\":\"2012-07-21T22:13:12.000Z\",\"image\":\"http://a0.twimg.com/profile_images/2536166028/image_normal.jpg\",\"summary\":\"Etudiant IUT GEA Dijon, ni ecrivain, ni philosophe, juste etudiant qui profite de sa jeunesse !\",\"links\":[{\"href\":null,\"rel\":\"me\"}],\"friendsCount\":96,\"followersCount\":72,\"listedCount\":0,\"statusesCount\":865,\"twitterTimeZone\":null,\"verified\":false,\"utcOffset\":null,\"preferredUsername\":\"SalletLucas\",\"languages\":[\"fr\"]},\"verb\":\"share\",\"postedTime\":\"2013-03-12T18:28:02.000Z\",\"generator\":{\"displayName\":\"Twitter for iPhone\",\"link\":\"http://twitter.com/download/iphone\"},\"provider\":{\"objectType\":\"service\",\"displayName\":\"Twitter\",\"link\":\"http://www.twitter.com\"},\"link\":\"http://twitter.com/SalletLucas/statuses/311544126913015809\",\"body\":\"RT @Snow_rider_blog: Un \xC3\xA9pisode magnifique ! @salomonfreeski #LT\",\"object\":{\"id\":\"tag:search.twitter.com,2005:311496971342999553\",\"objectType\":\"activity\",\"actor\":{\"objectType\":\"person\",\"id\":\"id:twitter.com:893001127\",\"link\":\"http://www.twitter.com/Snow_rider_blog\",\"displayName\":\"Snow_rider\",\"postedTime\":\"2012-10-20T10:54:13.000Z\",\"image\":\"http://a0.twimg.com/profile_images/2740666855/6fe3a929258911f53e7b6f081a7c0b64_normal.jpeg\",\"summary\":\"#Freeski, #Skiing, #Ski, #Snowboard, #Snow, #Freeride !\\r\\n\\r\\nThis is the real life !   \",\"links\":[{\"href\":\"http://snow-rider.tumblr.com/\",\"rel\":\"me\"}],\"friendsCount\":128,\"followersCount\":41,\"listedCount\":0,\"statusesCount\":465,\"twitterTimeZone\":null,\"verified\":false,\"utcOffset\":null,\"preferredUsername\":\"Snow_rider_blog\",\"languages\":[\"fr\"]},\"verb\":\"post\",\"postedTime\":\"2013-03-12T15:20:39.000Z\",\"generator\":{\"displayName\":\"web\",\"link\":\"http://twitter.com\"},\"provider\":{\"objectType\":\"service\",\"displayName\":\"Twitter\",\"link\":\"http://www.twitter.com\"},\"link\":\"http://twitter.com/Snow_rider_blog/statuses/311496971342999553\",\"body\":\"Un \xC3\xA9pisode magnifique ! @salomonfreeski #LT\",\"object\":{\"objectType\":\"note\",\"id\":\"object:search.twitter.com,2005:311496971342999553\",\"summary\":\"Un \xC3\xA9pisode magnifique ! @salomonfreeski #LT\",\"link\":\"http://twitter.com/Snow_rider_blog/statuses/311496971342999553\",\"postedTime\":\"2013-03-12T15:20:39.000Z\"},\"twitter_entities\":{\"hashtags\":[{\"text\":\"LT\",\"indices\":[40,43]}],\"urls\":[],\"user_mentions\":[{\"screen_name\":\"salomonfreeski\",\"name\":\"Salomon Freeski\",\"id\":54686213,\"id_str\":\"54686213\",\"indices\":[24,39]}]}},\"twitter_entities\":{\"hashtags\":[{\"text\":\"LT\",\"indices\":[61,64]}],\"urls\":[],\"user_mentions\":[{\"screen_name\":\"Snow_rider_blog\",\"name\":\"Snow_rider\",\"id\":893001127,\"id_str\":\"893001127\",\"indices\":[3,19]},{\"screen_name\":\"salomonfreeski\",\"name\":\"Salomon Freeski\",\"id\":54686213,\"id_str\":\"54686213\",\"indices\":[45,60]}]},\"twitter_filter_level\":\"medium\",\"retweetCount\":1},\"id\":\"311544126913015809\",\"available\":true},
        ]\r\n"

        None available:
        "[{\"id\":\"311232868594622458\",\"status\":\"not found\",\"available\":false},
          {\"id\":\"311232868594622453\",\"status\":\"not found\",\"available\":false},
          {\"id\":\"311232868594622447\",\"status\":\"not found\",\"available\":false},
          {\"id\":\"5ghghkhgj646464fhg\",\"status\":\"invalid ID format\",\"available\":false},
          {\"id\":\"286933899064524800\",\"status\":\"outside available timeframe\",\"available\":false}
        ]\r\n"

        Some available, some not:
        [
        {\"content\":{\"id\":\"tag:search.twitter.com,2005:311555603342430208\",\"objectType\":\"activity\",\"actor\":{\"objectType\":\"person\",\"id\":\"id:twitter.com:29319227\",\"link\":\"http://www.twitter.com/JustJazz_\",\"displayName\":\"medulla oblongata\",\"postedTime\":\"2009-04-06T23:05:42.000Z\",\"image\":\"http://a0.twimg.com/profile_images/3157436255/a7ac2252dfa48059357bc24bb82485d7_normal.jpeg\",\"summary\":\"Rasta style flower child \",\"links\":[{\"href\":null,\"rel\":\"me\"}],\"friendsCount\":253,\"followersCount\":275,\"listedCount\":2,\"statusesCount\":19490,\"twitterTimeZone\":\"Central Time (US & Canada)\",\"verified\":false,\"utcOffset\":\"-21600\",\"preferredUsername\":\"JustJazz_\",\"languages\":[\"en\"]},\"verb\":\"post\",\"postedTime\":\"2013-03-12T19:13:38.000Z\",\"generator\":{\"displayName\":\"Twitter for iPhone\",\"link\":\"http://twitter.com/download/iphone\"},\"provider\":{\"objectType\":\"service\",\"displayName\":\"Twitter\",\"link\":\"http://www.twitter.com\"},\"link\":\"http://twitter.com/JustJazz_/statuses/311555603342430208\",\"body\":\"It's hard to go to class when the weather is so nice\",\"object\":{\"objectType\":\"note\",\"id\":\"object:search.twitter.com,2005:311555603342430208\",\"summary\":\"It's hard to go to class when the weather is so nice\",\"link\":\"http://twitter.com/JustJazz_/statuses/311555603342430208\",\"postedTime\":\"2013-03-12T19:13:38.000Z\"},\"twitter_entities\":{\"hashtags\":[],\"urls\":[],\"user_mentions\":[]},\"twitter_filter_level\":\"medium\",\"retweetCount\":0},\"id\":\"311555603342430208\",\"available\":true},
        {\"id\":\"286933899064524800\",\"status\":\"outside available timeframe\",\"available\":false},
        {\"content\":{\"id\":\"tag:search.twitter.com,2005:311555604240019457\",\"objectType\":\"activity\",\"actor\":{\"objectType\":\"person\",\"id\":\"id:twitter.com:490488001\",\"link\":\"http://www.twitter.com/_AMAZN\",\"displayName\":\"Grace\",\"postedTime\":\"2012-02-12T16:13:43.000Z\",\"image\":\"http://a0.twimg.com/profile_images/3363242184/cb3416ab1f8f048603806a1d9b0ccc85_normal.jpeg\",\"summary\":\"Tombe-Pas de bourree-Glissade-Assemble \",\"links\":[{\"href\":null,\"rel\":\"me\"}],\"friendsCount\":294,\"followersCount\":328,\"listedCount\":1,\"statusesCount\":27516,\"twitterTimeZone\":\"Eastern Time (US & Canada)\",\"verified\":false,\"utcOffset\":\"-18000\",\"preferredUsername\":\"_AMAZN\",\"languages\":[\"en\"]},\"verb\":\"post\",\"postedTime\":\"2013-03-12T19:13:39.000Z\",\"generator\":{\"displayName\":\"TwitPal\",\"link\":\"http://bit.ly/fVzRUd\"},\"provider\":{\"objectType\":\"service\",\"displayName\":\"Twitter\",\"link\":\"http://www.twitter.com\"},\"link\":\"http://twitter.com/_AMAZN/statuses/311555604240019457\",\"body\":\"This rain is not regular.  Ugh\",\"object\":{\"objectType\":\"note\",\"id\":\"object:search.twitter.com,2005:311555604240019457\",\"summary\":\"This rain is not regular.  Ugh\",\"link\":\"http://twitter.com/_AMAZN/statuses/311555604240019457\",\"postedTime\":\"2013-03-12T19:13:39.000Z\"},\"twitter_entities\":{\"hashtags\":[],\"urls\":[],\"user_mentions\":[]},\"twitter_filter_level\":\"medium\",\"retweetCount\":0},\"id\":\"311555604240019457\",\"available\":true},
        {\"content\":{\"id\":\"tag:search.twitter.com,2005:311555604500082689\",\"objectType\":\"activity\",\"actor\":{\"objectType\":\"person\",\"id\":\"id:twitter.com:416776135\",\"link\":\"http://www.twitter.com/jedmoney22\",\"displayName\":\"Jordan Devan \",\"postedTime\":\"2011-11-20T04:10:00.000Z\",\"image\":\"http://a0.twimg.com/profile_images/3306116086/b42eeb8e0cc55a12c29e6ea54610533a_normal.jpeg\",\"summary\":null,\"links\":[{\"href\":null,\"rel\":\"me\"}],\"friendsCount\":139,\"followersCount\":135,\"listedCount\":0,\"statusesCount\":326,\"twitterTimeZone\":null,\"verified\":false,\"utcOffset\":null,\"preferredUsername\":\"jedmoney22\",\"languages\":[\"en\"]},\"verb\":\"share\",\"postedTime\":\"2013-03-12T19:13:39.000Z\",\"generator\":{\"displayName\":\"Twitter for iPhone\",\"link\":\"http://twitter.com/download/iphone\"},\"provider\":{\"objectType\":\"service\",\"displayName\":\"Twitter\",\"link\":\"http://www.twitter.com\"},\"link\":\"http://twitter.com/jedmoney22/statuses/311555604500082689\",\"body\":\"RT @Kourtneyyyy5: Every storm runs outta rain.Just like every dark night turns into day.Every heartache will fade away just like every s ...\",\"object\":{\"id\":\"tag:search.twitter.com,2005:311543267764359168\",\"objectType\":\"activity\",\"actor\":{\"objectType\":\"person\",\"id\":\"id:twitter.com:718949804\",\"link\":\"http://www.twitter.com/Kourtneyyyy5\",\"displayName\":\"Kourtney\",\"postedTime\":\"2012-07-26T23:02:51.000Z\",\"image\":\"http://a0.twimg.com/profile_images/2828669590/89caf1d0d20576ba31c04a28ddb07de2_normal.jpeg\",\"summary\":\"You either love me or hate me,\",\"links\":[{\"href\":null,\"rel\":\"me\"}],\"friendsCount\":252,\"followersCount\":198,\"listedCount\":0,\"statusesCount\":1547,\"twitterTimeZone\":null,\"verified\":false,\"utcOffset\":null,\"preferredUsername\":\"Kourtneyyyy5\",\"languages\":[\"en\"]},\"verb\":\"post\",\"postedTime\":\"2013-03-12T18:24:37.000Z\",\"generator\":{\"displayName\":\"Twitter for iPhone\",\"link\":\"http://twitter.com/download/iphone\"},\"provider\":{\"objectType\":\"service\",\"displayName\":\"Twitter\",\"link\":\"http://www.twitter.com\"},\"link\":\"http://twitter.com/Kourtneyyyy5/statuses/311543267764359168\",\"body\":\"Every storm runs outta rain.Just like every dark night turns into day.Every heartache will fade away just like every storm runs out of rain\",\"object\":{\"objectType\":\"note\",\"id\":\"object:search.twitter.com,2005:311543267764359168\",\"summary\":\"Every storm runs outta rain.Just like every dark night turns into day.Every heartache will fade away just like every storm runs out of rain\",\"link\":\"http://twitter.com/Kourtneyyyy5/statuses/311543267764359168\",\"postedTime\":\"2013-03-12T18:24:37.000Z\"},\"twitter_entities\":{\"hashtags\":[],\"urls\":[],\"user_mentions\":[]}},\"twitter_entities\":{\"hashtags\":[],\"urls\":[],\"user_mentions\":[{\"screen_name\":\"Kourtneyyyy5\",\"name\":\"Kourtney\",\"id\":718949804,\"id_str\":\"718949804\",\"indices\":[3,16]}]},\"twitter_filter_level\":\"medium\",\"retweetCount\":1},\"id\":\"311555604500082689\",\"available\":true},
        {\"content\":{\"id\":\"tag:search.twitter.com,2005:311555604705583105\",\"objectType\":\"activity\",\"actor\":{\"objectType\":\"person\",\"id\":\"id:twitter.com:280301054\",\"link\":\"http://www.twitter.com/larrysbaker\",\"displayName\":\"Shannon Baker\",\"postedTime\":\"2011-04-11T02:12:03.000Z\",\"image\":\"http://a0.twimg.com/profile_images/2705574908/90cd59d28acd327a2a1cace597353a0f_normal.jpeg\",\"summary\":\"Flight paramedic for Pedi-flite at Le Bonheur Children's Hospital. Father of 2 boys. Southern gentleman and a Ole Miss Rebel fan. Czar of ambulance driving.\",\"links\":[{\"href\":null,\"rel\":\"me\"}],\"friendsCount\":737,\"followersCount\":257,\"listedCount\":2,\"statusesCount\":182,\"twitterTimeZone\":\"Central Time (US & Canada)\",\"verified\":false,\"utcOffset\":\"-21600\",\"preferredUsername\":\"larrysbaker\",\"languages\":[\"en\"],\"location\":{\"objectType\":\"place\",\"displayName\":\"Memphis, TN\"}},\"verb\":\"post\",\"postedTime\":\"2013-03-12T19:13:39.000Z\",\"generator\":{\"displayName\":\"web\",\"link\":\"http://twitter.com\"},\"provider\":{\"objectType\":\"service\",\"displayName\":\"Twitter\",\"link\":\"http://www.twitter.com\"},\"link\":\"http://twitter.com/larrysbaker/statuses/311555604705583105\",\"body\":\"Just had a nice run on this spring break.  The weather makes me wish I was other places. #BringOnTheSpring\",\"object\":{\"objectType\":\"note\",\"id\":\"object:search.twitter.com,2005:311555604705583105\",\"summary\":\"Just had a nice run on this spring break.  The weather makes me wish I was other places. #BringOnTheSpring\",\"link\":\"http://twitter.com/larrysbaker/statuses/311555604705583105\",\"postedTime\":\"2013-03-12T19:13:39.000Z\"},\"twitter_entities\":{\"hashtags\":[{\"text\":\"BringOnTheSpring\",\"indices\":[89,106]}],\"urls\":[],\"user_mentions\":[]},\"twitter_filter_level\":\"medium\",\"retweetCount\":0},\"id\":\"311555604705583105\",\"available\":true},
        {\"id\":\"311555604240019458\",\"status\":\"not found\",\"available\":false},
        {\"content\":{\"id\":\"tag:search.twitter.com,2005:311555598112141312\",\"objectType\":\"activity\",\"actor\":{\"objectType\":\"person\",\"id\":\"id:twitter.com:53688584\",\"link\":\"http://www.twitter.com/SheLbbbbO\",\"displayName\":\"Shellbbitch\",\"postedTime\":\"2009-07-04T15:15:26.000Z\",\"image\":\"http://a0.twimg.com/profile_images/3276335778/2a1e484d74086ded9e4fbde0404cf606_normal.jpeg\",\"summary\":\"Don't believe me, just watch.\",\"links\":[{\"href\":null,\"rel\":\"me\"}],\"friendsCount\":130,\"followersCount\":329,\"listedCount\":0,\"statusesCount\":35194,\"twitterTimeZone\":\"Quito\",\"verified\":false,\"utcOffset\":\"-18000\",\"preferredUsername\":\"SheLbbbbO\",\"languages\":[\"en\"]},\"verb\":\"post\",\"postedTime\":\"2013-03-12T19:13:37.000Z\",\"generator\":{\"displayName\":\"Twitter for iPad\",\"link\":\"http://twitter.com/#!/download/ipad\"},\"provider\":{\"objectType\":\"service\",\"displayName\":\"Twitter\",\"link\":\"http://www.twitter.com\"},\"link\":\"http://twitter.com/SheLbbbbO/statuses/311555598112141312\",\"body\":\"\xE2\x80\x9C@mormoncuddly: You are the smell before rain, you are the blood in my veins\xE2\x80\x9D\",\"object\":{\"objectType\":\"note\",\"id\":\"object:search.twitter.com,2005:311555598112141312\",\"summary\":\"\xE2\x80\x9C@mormoncuddly: You are the smell before rain, you are the blood in my veins\xE2\x80\x9D\",\"link\":\"http://twitter.com/SheLbbbbO/statuses/311555598112141312\",\"postedTime\":\"2013-03-12T19:13:37.000Z\"},\"inReplyTo\":{\"link\":\"http://twitter.com/mormoncuddly/statuses/311550423540588547\"},\"twitter_entities\":{\"hashtags\":[],\"urls\":[],\"user_mentions\":[{\"screen_name\":\"mormoncuddly\",\"name\":\"Sarah\",\"id\":318885671,\"id_str\":\"318885671\",\"indices\":[1,14]}]},\"twitter_filter_level\":\"medium\",\"retweetCount\":0},\"id\":\"311555598112141312\",\"available\":true}]\r\n"

=end

#=======================================================================================================================
'''
ReHydration Class.

'''
class PtRehydration
    require "json"
    require "yaml"          #Used for configuration files.
    require "base64"
    require "fileutils"

    ID_API_REQUEST_LIMIT = 25 #Limit on the number of activity IDs per Rehydration API request.

    attr_accessor :http,  #Rehydration object needs a HTTP object to make requests of.
                  :datastore, #Rehydration object can use a database object to store data.
                  :account_name, :user_name, :password, #System authentication.
                  :publisher, :product, :stream_type,
                  :id_request_list, :id_na_list, :id_old_list,
                  :in_box, :out_box, :out_box_na, :out_box_old
                  :storage

    def initialize(config_file)
        #class variables.
        @@base_url = "https://rehydration.gnip.com:443/accounts/"

        #Initialize stuff.
        @id_request_list = Array.new
        @id_na_list = Array.new
        @id_old_list = Array.new

        #Defaults.
        @publisher = "twitter"
        @product = "rehydration"

        getSystemConfig(config_file)  #Load the oHistorical PowerTrack account details.

        #Set up a HTTP object.
        @http = PtREST.new  #Historical API is REST based (currently).
        @http.publisher = @publisher
        @http.user_name = @user_name  #Set the info needed for authentication.
        @http.password_encoded = @password_encoded  #HTTP class can decrypt password.
        @http.url=@http.getRehydrationURL(@account_name)  #Pass the URL to the HTTP object.
    end

    #Confirm a directory exists, creating it if neccessary.
    def checkDirectory(directory)
        #Make sure directory exists, making it if needed.
        if not File.directory?(directory) then
            FileUtils.mkpath(directory) #logging and user notification.
        end
        directory
    end

    #Load in the configuration file details, setting many object attributes.
    def getSystemConfig(config_file)

        config = YAML.load_file(config_file)

        #Config details.
        @account_name = config["account"]["account_name"]
        @user_name  = config["account"]["user_name"]
        @password_encoded = config["account"]["password_encoded"]

        if @password_encoded.nil? then  #User is passing in plain-text password...
            @password = config["config"]["account"]
            @password_encoded = Base64.encode64(@password)
        end

        #User-specified in and out boxes.
        @in_box = checkDirectory(config["rehydration"]["in_box"])
        #Managing request lists that have been processed.
        @in_box_completed = checkDirectory(config["rehydration"]["in_box_completed"])
        @out_box = checkDirectory(config["rehydration"]["out_box"])

        @storage = config["rehydration"]["storage"]

        if @storage == "database" then #Get database connection details.
            db_host = config["database"]["host"]
            db_port = config["database"]["port"]
            db_schema = config["database"]["schema"]
            db_user_name = config["database"]["user_name"]
            db_password  = config["database"]["password"]

            @datastore = PtDatabase.new(db_host, db_port, db_schema, db_user_name, db_password)
            @datastore.connect
        end

        #Managing IDs that were not available.
        @keep_na_files = config["rehydration"]["keep_na_files"]
        @out_box_na = checkDirectory(config["rehydration"]["out_box_na"])
        @out_box_old = checkDirectory(config["rehydration"]["out_box_old"])

        #Defaults
        @stream_type = config["rehydration"]["stream_type"]

    end

    #TODO: not used yet - could be used for timestamping "not available/old" id list filenames.
    def getFileDateString
        Time.now.strftime('%Y%m%d-%H%M%S')
    end

    '''
    Handle tweets IDs that were not available.

        Script options:
        keep_na_files: true #Save [tweet_id].na and [tweet_id].old for unavailable IDs?
        out_box_na: ./rehydration_out/na_ids #Folder where retrieved data goes.
        out_box_old: ./rehydration_out/old_ids #Folder where retrieved data goes.
    '''
    def handleNotAvailable(activity)

        #p "Activity was not available: " + activity["status"]
        if activity["status"].include?("timeframe") then
            #Add to list of old activities.
            @id_old_list << activity["id"]

            if @keep_na_files then
                #Write ID.old file.
                File.open(@out_box_old + "/" + activity["id"] + ".old", "w") do |new_file|
                    new_file.write(activity["id"] + " => " + activity["status"])
                end
            end
        elsif activity["status"].include?("not found") or activity["status"].include?("invalid ID") then
            #Add to list of not available activities.
            @id_na_list << activity["id"]

            if @keep_na_files then
                #Write ID.na file.
                File.open(@out_box_na + "/" + activity["id"] + ".na", "w") do |new_file|
                    new_file.write(activity["id"] + " => " + activity["status"])
                end
            end
        end




    end

    '''
    Process this single API response.
    May have up to ID_API_REQUEST_LIMIT activities to handle.
    Currently this method writes the activity data to the out_box.

    This is where you would implement any other datastore strategy.
    '''
    def processResponse(response)

        response_hash = JSON.parse(response) #Converting JSON payload to hash

        response_hash.each do |activity|
            if activity["available"] then
                #p "Activity is available..."
                #Grab activity ID for file name
                if @storage == "files" then
                    File.open(@out_box + "/" + activity["id"] + ".json", "wb") do |new_file|
                        new_file.write(activity["content"].to_json)  #Write as JSON.
                    end
                else
                   @datastore.storeActivity(activity["content"].to_json)  #Pass in as JSON.
                end
            else
                handleNotAvailable(activity)
            end
        end
    end

    #Parses request files and returns an array of ids.
    def parseRequestList(contents)
        #Test for different delimiters.
        if contents.include?(",") then  #We have a CSV file.
            contents.gsub!(/\s+/,"")
            ids = contents.split(",")
        elsif contents.include?("\t") then #We have a TAB-delimited file.
            ids = contents.split("\t")
        elsif contents.include?("\n") then #We have a new-line-delimited file.
            ids = contents.split("\n")
        elsif contents.include?(" ") then #We have a TAB-delimited file.
            ids = contents.split(" ")
        else
            contents.gsub!(/\s+/,"")
            ids = contents.split(/\D/)  #The catch all, will split on any non-digit character (space, | whatever)
        end

        @id_request_list = ids
    end

    #Write a list of unavailable tweet IDs to a file.
    def writeList(not_found_type, not_found_array)

        filename = "ids_" + not_found_type

        #Write list to file.
        attribute = "out_box_" + not_found_type
        File.open(self.send(attribute.to_sym) + "/" + filename + ".dat", "a") do |new_file|
            new_file.write(not_found_array.to_json)
        end
    end

    #Mange the requests to the Rehydration API.
    def manageRequests

        @id_request_list.each_slice(ID_API_REQUEST_LIMIT) do |id_group|  #Request up to the max number of requests.

            #Create data payload for POST request.
            request_ids  = {}
            request_ids["ids"]  = id_group  #assign the id list to the "ids" key.
            data = request_ids.to_json #convert to json for the API request.

            p "Making request of Rehydration API..."
            response = @http.POST(data) #Go get data from Rehydration API.

            processResponse(response.body) #Process response.
        end
    end

    '''
    #The current do-all method...
    #This method loads files in the in-box,
    #Triggers the management of the requests to the Rehydration API,
    #and manages the production of output files.
    #  --data "{\"ids\":[\"311236001483874305\",\"311236104277860354\"]}"
    '''
    def getActivities

        #Look in inbox and process files found there.
        Dir.foreach(@in_box) do |item|
            #Skip directory references.
            next if item == "." or item == ".."   #Skip parent and this directory "file."
            next if File.directory?(@in_box + "/" + item)  #Skip other sub-directories.

            #Open file and read contents.
            f = File.open(@in_box + "/" + item,'r')
            contents = f.read
            contents.strip! #Remove leading and trailing white-space

            @id_request_list = parseRequestList(contents)

            manageRequests #Mange the requests to the Rehydration API.

            #We are finished processing data, so do some clean-up and file management.

            #Move ID file to "completed" subfolder.  Folder was created (if needed) when object was created.
            FileUtils.mv(@in_box + "/" + item, @in_box_completed + "/" + item)

            #Write the not available and old id list files.
            writeList("na", @id_na_list)
            writeList("old", @id_old_list)
        end
    end
end #PtHydration class

#=======================================================================================================================
#A simple RESTful HTTP class put together for this Rehydration script.
#Future versions will most likely use an external PtREST object, common to all PowerTrack ruby clients.
class PtREST
    require "net/https"     #HTTP gem.
    require "uri"

    attr_accessor :url, :uri, :user_name, :password_encoded, :headers, :data, :data_agent, :account_name, :publisher

    def initialize(url=nil, user_name=nil, password_encoded=nil, headers=nil)
        if not url.nil?
            @url = url
        end

        if not user_name.nil?
            @user_name = user_name
        end

        if not password_encoded.nil?
            @password_encoded = password_encoded
            @password = Base64.decode64(@password_encoded)
        end

        if not headers.nil?
            @headers = headers
        end
    end

    def url=(value)
        @url = value
        @uri = URI.parse(@url)
    end

    def password_encoded=(value)
        @password_encoded=value
        if not @password_encoded.nil? then
            @password = Base64.decode64(@password_encoded)
        end
    end

    #Helper function for building URsL.
    def getRehydrationURL(account_name=nil)
        @url = "https://rehydration.gnip.com:443/accounts/"  #Root url for Rehydration PowerTrack.

        if account_name.nil? then #using object account_name attribute.
            if @account_name.nil?
                p "No account name set.  Can not set url."
            else
                @url = @url + @account_name + "/publishers/" + @publisher + "/rehydration/activities.json"
            end
        else #account_name passed in, so use that...
            @url = @url + account_name + "/publishers/" + @publisher + "/rehydration/activities.json"
        end
    end

    #Fundamental REST API methods:
    def POST(data=nil)

        if not data.nil? #if request data passed in, use it.
            @data = data
        end

        uri = URI(@url)
        http = Net::HTTP.new(uri.host, uri.port)
        http.use_ssl = true
        request = Net::HTTP::Post.new(uri.path)
        request.body = @data
        request.basic_auth(@user_name, @password)
        response = http.request(request)
        return response
    end

    def PUT(data=nil)

        if not data.nil? #if request data passed in, use it.
            @data = data
        end

        uri = URI(@url)
        http = Net::HTTP.new(uri.host, uri.port)
        http.use_ssl = true
        request = Net::HTTP::Put.new(uri.path)
        request.body = @data
        request.basic_auth(@user_name, @password)
        response = http.request(request)
        return response
    end

    def GET(params=nil)
        uri = URI(@url)

        #params are passed in as a hash.
        #Example: params["max"] = 100, params["since_date"] = 20130321000000
        if not params.nil?
            uri.query = URI.encode_www_form(params)
        end

        http = Net::HTTP.new(uri.host, uri.port)
        http.use_ssl = true
        request = Net::HTTP::Get.new(uri.request_uri)
        request.basic_auth(@user_name, @password)

        response = http.request(request)
        return response
    end

    def DELETE(data=nil)
        if not data.nil?
            @data = data
        end

        uri = URI(@url)
        http = Net::HTTP.new(uri.host, uri.port)
        http.use_ssl = true
        request = Net::HTTP::Delete.new(uri.path)
        request.body = @data
        request.basic_auth(@user_name, @password)
        response = http.request(request)
        return response
    end
end #PtREST class.


#=======================================================================================================================
#Database class.

'''
This class is meant to demonstrate basic code for building a "database" class for use with the
PowerTrack set of example code.  It is written in Ruby, but in its present form hopefully will
read like pseudo-code for other languages.

One option would be to use (Rails) ActiveRecord for data management, but it seems that may abstract away more than
desired.

Having said that, the database was created (and maintained/migrated) with Rails ActiveRecord.
It is just a great way to create databases.

ActiveRecord::Schema.define(:version => 20130306234839) do

  create_table "activities", :force => true do |t|
      t.integer  "native_id",   :limit => 8
      t.text     "content"
      t.text     "body"
      t.string   "rule_value"
      t.string   "rule_tag"
      t.string   "publisher"
      t.string   "job_uuid"
      t.datetime "created_at",               :null => false
      t.datetime "updated_at",               :null => false
      t.float    "latitude"
      t.float    "longitude"
      t.datetime "posted_time"
  end

end

The above table fields are a bit arbitrary.  I cherry picked some Tweet details and promoted them to be table fields.
Meanwhile the entire tweet is stored, in case other parsing is needed downstream.
'''
class PtDatabase
    require "mysql2"
    require "time"
    require "json"
    require "base64"

    attr_accessor :client, :host, :port, :user_name, :password, :database, :sql

    def initialize(host=nil, port=nil, database=nil, user_name=nil, password=nil)
        #local database for storing activity data...

        if host.nil? then
            @host = "127.0.0.1" #Local host is default.
        else
            @host = host
        end

        if port.nil? then
            @port = 3306 #MySQL post is default.
        else
            @port = port
        end

        if not user_name.nil?  #No default for this setting.
            @user_name = user_name
        end

        if not password.nil? #No default for this setting.
            @password = password
        end

        if not database.nil? #No default for this setting.
            @database = database
        end
    end

    #You can pass in a PowerTrack configuration file and load details from that.
    def config=(config_file)
        @config = config_file
        getSystemConfig(@config)
    end


    #Load in the configuration file details, setting many object attributes.
    def getSystemConfig(config)

        config = YAML.load_file(config_file)

        #Config details.
        @host = config["database"]["host"]
        @port = config["database"]["port"]

        @user_name = config["database"]["user_name"]
        @password_encoded = config["database"]["password_encoded"]

        if @password_encoded.nil? then  #User is passing in plain-text password...
            @password = config["database"]["password"]
            @password_encoded = Base64.encode64(@password)
        end

        @database = config["database"]["schema"]
    end


    def to_s
        "PowerTrack object => " + @host + ":" + @port.to_s + "@" + @user_name + " schema:" + @database
    end

    def connect
        #TODO: need support for password!
        @client = Mysql2::Client.new(:host => @host, :port => @port, :username => @user_name, :database => @database )
    end

    def disconnect
        @client.close
    end

    def SELECT(sql = nil)

        if sql.nil? then
            sql = @sql
        end

        result = @client.query(sql)

        result

    end

    def UPDATE(sql)
    end

    def REPLACE(sql)
        begin
            result = @client.query(sql)
            true
        rescue
            false
        end
    end

    #NativeID is defined as an integer.  This works for Twitter, but not for other publishers who use alphanumerics.
    #Tweet "id" field has this form: "tag:search.twitter.com,2005:198308769506136064"
    #This function parses out the numeric ID at end.
    def getNativeID(id)
        native_id = Integer(id.split(":")[-1])
    end

    #Twitter uses UTC.
    def getPostedTime(time_stamp)
        time_stamp = Time.parse(time_stamp).strftime("%Y-%m-%d %H:%M:%S")
    end

    #With Rehydration, there are no rules, just requested IDs.
    def getMatchingRules(matching_rules)
        return "rehydration", "rehydration"
    end

    '''
    Parse the activity payload and get the lat/long coordinates.
    ORDER MATTERS: Latitude, Longitude.

    #An example here we have POINT coordinates.
    "location":{
        "objectType":"place",
        "displayName":"Jefferson Southwest, KY",
        "name":"Jefferson Southwest",
        "country_code":"United States",
        "twitter_country_code":"US",
        "link":"http://api.twitter.com/1/geo/id/7a46e5213d3a1af2.json",
        "geo":{
            "type":"Polygon",
            "coordinates":[[[-85.951854,37.997244],[-85.700857,37.997244],[-85.700857,38.233633],[-85.951854,38.233633]]]}
    },
    "geo":{"type":"Point","coordinates":[38.1341,-85.8953]},
    '''

    def getGeoCoordinates(activity)

        geo = activity["geo"]
        latitude = 0
        longitude = 0

        if not geo.nil? then #We have a "root" geo entry, so go there to get Point location.
            if geo["type"] == "Point" then
                latitude = geo["coordinates"][0]
                longitude = geo["coordinates"][1]

                #We are done here, so return
                return latitude, longitude

            end
        end

        #p activity["location"]
        #p activity["location"]["geo"]
        #p activity["geo"]

        return latitude, longitude
    end

    #Replace some special characters with an _.
    #(Or, for Ruby, use ActiveRecord for all db interaction!)
    def handleSpecialCharacters(text)

        if text.include?("'") then
            text.gsub!("'","_")
        end
        if text.include?("\\") then
            text.gsub!("\\","_")
        end

        text
    end


    '''
    storeActivity
    Receives an Activity Stream data point formatted in JSON.
    Does some (hopefully) quick parsing of payload.
    Writes to an Activities table.

    t.integer  "native_id",   :limit => 8
    t.text     "content"
    t.text     "body"
    t.string   "rule_value"
    t.string   "rule_tag"
    t.string   "publisher"
    t.string   "job_uuid"  #Used for Historical PowerTrack.
    t.float    "latitude"
    t.float    "longitude"
    t.datetime "posted_time"
    '''

    def storeActivity(activity, uuid = nil)

        data = JSON.parse(activity)

        #Handle uuid if there is not one (tweet not returned by Historical API)
        if uuid == nil then
            uuid = ""
        end

        #Parse from the activity the "atomic" elements we are inserting into db fields.

        post_time = getPostedTime(data["postedTime"])

        native_id = getNativeID(data["id"])

        body = handleSpecialCharacters(data["body"])

        content = handleSpecialCharacters(activity)

        #Parse gnip:matching_rules and extract one or more rule values/tags
        rule_values, rule_tags  = "rehydration", "rehydration" #getMatchingRules(data["gnip"]["matching_rules"])

        #Parse the activity and extract any geo available data.
        latitude, longitude = getGeoCoordinates(data)

        #Build SQL.
        sql = "REPLACE INTO activities (native_id, posted_time, content, body, rule_value, rule_tag, publisher, job_uuid, latitude, longitude, created_at, updated_at ) " +
            "VALUES (#{native_id}, '#{post_time}', '#{content}', '#{body}', '#{rule_values}','#{rule_tags}','Twitter', '#{uuid}', #{latitude}, #{longitude}, UTC_TIMESTAMP(), UTC_TIMESTAMP());"

        if not REPLACE(sql) then
            p "Activity not written to database: " + activity.to_s
        end
    end
end #PtDB class.


#=======================================================================================================================
if __FILE__ == $0  #This script code is executed when running this file.
    require 'optparse'

    OptionParser.new do |o|
        o.on('-c CONFIG') { |config| $config = config}
        o.parse!
    end

    if $config.nil? then
        $config = "./PowerTrackConfig_private.yaml"  #Default
    end

    #Create a Rehyrdation PowerTrack object, passing in an account configuration file.
    p "Creating PT Rehydration object with config file: " + $config
    oRehy = PtRehydration.new($config)

    #The "do all" method, utilizes many other methods to retrieve the requested ids.
    oRehy.getActivities

    p "Exiting"

end