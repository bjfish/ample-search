# Overview
[AmpleSearch](https://www.amplesearch.com/) is a Rails Application which indexes a user's web application data by authorizing connections to external applications using OAuth and retrieving a users data using REST APIs. This allows a user to search all of there web application data in one location.

This sample contains three projects:

* indexer - the main Rails application
* indexer-worker - a resque project which processes indexing jobs 
* indexer_jobs - a library with jobs shared between indexer and indexer-worker projects

An previous prototype screencast is available [here](https://www.dropbox.com/s/jd5k7y0dm3xxjx2/prototype_index.avi) to demonstrate the basic application functionality.