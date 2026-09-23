cd ~/qdi-api-image
RTR=$(sudo docker ps --filter name=router_router -q | head -1)
sudo docker cp api.conf "$RTR":/etc/nginx/conf.d/zz_api_test.conf
sudo docker exec "$RTR" nginx -t
sudo docker exec "$RTR" rm -f /etc/nginx/conf.d/zz_api_test.conf
sudo docker exec "$RTR" ls /etc/nginx/conf.d/
