# FastDFS-AllForOne
FastDFS单机版、集群版，统一集成版本<br/>

配置文件拷贝<br/>
docker run -ti -d --name storage kenny14/nginx-fastdfs:v1 storage<br/>
docker cp -a 154f19ab263c:/etc/fdfs/.  /usr/local/fastdfs/etc<br/>


<单机><br/>
tracker:<br/>
快速启动<br/>
docker run -dit --net=host --name tracker -v /etc/localtime:/etc/localtime kenny14/nginx-fastdfs:v1 tracker<br/>
挂载配置<br/>
docker run -dit --net=host --name tracker -v /usr/local/build/conf/tracker.conf:/etc/fdfs/tracker.conf -v /usr/local/fastdfs/tracker:/usr/local/fastdfs/tracker -v /etc/localtime:/etc/localtime kenny14/nginx-fastdfs:v1 tracker<br/>

storage:<br/>
创建目录文件<br/>
mkdir -p /usr/local/fastdfs/storage/logs/<br/>
touch storaged.log<br/>
快速启动<br/>
docker run -dit --name storage -v /etc/localtime:/etc/localtime --net=host -e TRACKER_SERVER=IP地址:22122 kenny14/nginx-fastdfs:v1 storage<br/>
挂载配置<br/>
docker run -dit --name storage -v  /usr/local/fastdfs/storage:/usr/local/fastdfs/storage  -v /etc/localtime:/etc/localtime --net=host -e TRACKER_SERVER=IP地址:22122 kenny14/nginx-fastdfs:v1 storage<br/>

monitor:<br/>
docker run -dit --net=host --name monitor -e TRACKER_SERVER=IP地址:22122 kenny14/nginx-fastdfs:v1 monitor<br/>

<集群><br/>
tracker:<br/>
挂载配置<br/>
docker run -dit --net=host --name tracker -v /etc/fdfs/tracker.conf:/etc/fdfs/tracker.conf -v /usr/local/fastdfs/tracker:/usr/local/fastdfs/tracker kenny14/nginx-fastdfs:v1 tracker<br/>

storage:<br/>
创建目录文件<br/>
mkdir -p /usr/local/fastdfs/storage/logs/<br/>
touch storaged.log<br/>
挂载配置<br/>
docker run -dit --name storage -v /usr/local/fastdfs/storage:/usr/local/fastdfs/storage -v /usr/local/fastdfs/etc/storage.conf:/etc/fdfs/storage.conf -v /usr/local/nginx/mod_fastdfs.conf:/etc/fdfs/mod_fastdfs.conf -v /etc/localtime:/etc/localtime --net=host -e TRACKER_SERVER=IP地址:22122 kenny14/nginx-fastdfs:v1 storage<br/>

monitor:<br/>
docker run -dit --net=host --name monitor -e TRACKER_SERVER=IP地址:22122 kenny14/nginx-fastdfs:v1 monitor<br/>