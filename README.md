# Skyline Docker Wrapper
Skyline is an open source anomaly detection system.
We have modernized the platform to simple deployment using docker-compose. 
It’s simple to run, configure and test this on your local environment and in production

This repository only handles the deployment of the environment, as the regular configuration of the environment is quite long and complicated, and has a lot of “fine-tuning”. Handling metrics configurations should be handled under the main skyline repository (https://github.com/wix-playground/skyline.git) 

## Configuring startup variables
- Go to /skyline_docker/config and edit the configuration_file with your values and configurations.
- Once the values are correct run `docker-compose build`
- When build is done run `docker-compose up`
- Check the logs for any errors! 

## Working with external hosts (Not the docker ones)
- Redis: update the `config/redis/redis.conf` "bind" section to your server ip
- Mysql server: update PANORAMA_DBHOST with your DB server ip 

