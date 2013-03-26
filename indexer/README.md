# Requirements to run locally
-   Start redis server with default settings
-   Start elastic search server with default settings
-   Load the required environment vars using a batch script
-   Start resque worker with the command:  `bundle exec rake environment resque:work`
-   Start rails

# Issue on deploy resolution
https://forums.aws.amazon.com/message.jspa?messageID=403343#403343
I get this problem on redeploy, I think it is a bug in the Amazon code that it can not handle non-ascii (utf-8) output code.

solution I use is to review the logs - if everything looks good, then

ssh to instance
sudo /opt/elasticbeanstalk/hooks/appdeploy/enact/01_flip.sh
sudo /opt/elasticbeanstalk/hooks/appdeploy/enact/99_reload_app_server.sh