# FastDFS-AllForOne
FastDFS单机版、集群版，统一集成版本

配置文件拷贝
docker run -ti -d --name storage kenny14/nginx-fastdfs:v1 storage
docker cp -a 154f19ab263c:/etc/fdfs/.  /usr/local/fastdfs/etc


<单机>
tracker:
快速启动
docker run -dit --net=host --name tracker -v /etc/localtime:/etc/localtime kenny14/nginx-fastdfs:v1 tracker
挂载配置
docker run -dit --net=host --name tracker -v /usr/local/build/conf/tracker.conf:/etc/fdfs/tracker.conf -v /usr/local/fastdfs/tracker:/usr/local/fastdfs/tracker -v /etc/localtime:/etc/localtime kenny14/nginx-fastdfs:v1 tracker

storage:
创建目录文件
mkdir -p /usr/local/fastdfs/storage/logs/
touch storaged.log
快速启动
docker run -dit --name storage -v /etc/localtime:/etc/localtime --net=host -e TRACKER_SERVER=IP地址:22122 kenny14/nginx-fastdfs:v1 storage
挂载配置
docker run -dit --name storage -v  /usr/local/fastdfs/storage:/usr/local/fastdfs/storage  -v /etc/localtime:/etc/localtime --net=host -e TRACKER_SERVER=IP地址:22122 kenny14/nginx-fastdfs:v1 storage

monitor:
docker run -dit --net=host --name monitor -e TRACKER_SERVER=IP地址:22122 kenny14/nginx-fastdfs:v1 monitor

<集群>
tracker:
挂载配置
docker run -dit --net=host --name tracker -v /etc/fdfs/tracker.conf:/etc/fdfs/tracker.conf -v /usr/local/fastdfs/tracker:/usr/local/fastdfs/tracker kenny14/nginx-fastdfs:v1 tracker

storage:
创建目录文件
mkdir -p /usr/local/fastdfs/storage/logs/
touch storaged.log
挂载配置
docker run -dit --name storage -v /usr/local/fastdfs/storage:/usr/local/fastdfs/storage -v /usr/local/fastdfs/etc/storage.conf:/etc/fdfs/storage.conf -v /usr/local/nginx/mod_fastdfs.conf:/etc/fdfs/mod_fastdfs.conf -v /etc/localtime:/etc/localtime --net=host -e TRACKER_SERVER=IP地址:22122 kenny14/nginx-fastdfs:v1 storage

monitor:
docker run -dit --net=host --name monitor -e TRACKER_SERVER=IP地址:22122 kenny14/nginx-fastdfs:v1 monitor