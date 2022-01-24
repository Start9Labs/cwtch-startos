# Instructions for Cwtch

Cwtch takes the following arguments

    -exportServerBundle: Export the server bundle to a file called serverbundle
    -disableMetrics: Disable metrics reporting to serverMonitor.txt and associated tracking routines
    -dir [directory]: specify a directory to store server files (default is current directory)

The app takes the following environment variables

    CWTCH_HOME: sets the config dir for the app
    DISABLE_METRICS: if set to any value ('1') it disables metrics reporting to serverMonitor.txt and associated tracking routines

# Using the Server 

When run the app will output standard log lines, one of which will contain the serverbundle in purple. 

This is the part you need to capture and import into a Cwtch client app so you can use the server for hosting groups