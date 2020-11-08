# README
### (Ubuntu) After install, you need to run this cmd to edit files
sudo chown -R $USER:$USER .

### For React template and PostgreSQL
docker-compose run --no-deps NAME-PROJECT rails new . --force --webpack=react --database=postgresql


### Api example 
docker-compose run --no-deps NAME-PROJECT rails new . --force --api
