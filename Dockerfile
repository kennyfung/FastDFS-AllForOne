FROM centos:centos7.7.1908

MAINTAINER kenny <fw_long@163.com>

ENV TOOLS=/usr/local/tools \
    FASTDFS_BASE_PATH=/usr/local/fastdfs \
    PORT= \
    GROUP_NAME= \
    TRACKER_SERVER= \
    NGINX_PORT= \
    IS_CLUSTER=

#新建目录
RUN mkdir ${TOOLS} \
    && mkdir ${FASTDFS_BASE_PATH} \
    && mkdir ${FASTDFS_BASE_PATH}/tracker \
    && mkdir ${FASTDFS_BASE_PATH}/storage \
    && mkdir -p /home/yuqing/fastdfs

#安装准备
RUN yum install -y git gcc make wget zlib zlib-dev pcre pcre-devel openssl openssl-devel \
    && rm -rf /var/cache/yum/*

#RUN apk update \
#    && apk add --no-cache git gcc gcc-c++ make automake autoconf libtool pcre pcre-dev zlib zlib-dev openssl-dev wget vim --repository https://mirrors.tuna.tsinghua.edu.cn/alpine/v3.6/main

#下载fastdfs、libfastcommon、nginx、以及nginx所属插件等源码
RUN cd ${TOOLS} \
    && git clone https://github.com/happyfish100/libfastcommon.git --depth 1 \
    && git clone https://github.com/happyfish100/fastdfs.git --depth 1 \
    && git clone https://github.com/happyfish100/fastdfs-nginx-module.git --depth 1 \
    && wget http://nginx.org/download/nginx-1.17.0.tar.gz

#安装libfastcommon
WORKDIR ${TOOLS}/libfastcommon/
RUN ./make.sh  \
    && ./make.sh install

#安装fastdfs
WORKDIR ${TOOLS}/fastdfs/
RUN ./make.sh \
    && ./make.sh install

#安裝nginx
WORKDIR ${TOOLS}
RUN tar -zxvf nginx-1.17.0.tar.gz \
    && cd nginx-1.17.0/ \
    && ./configure --add-module=${TOOLS}/fastdfs-nginx-module/src \
    && make \
    && make install

#设置nginx配置
RUN echo -e "\
    worker_processes  1;\n\
    #daemon off;\n\
    events {\n\
        worker_connections  1024;\n\
    }\n\
    http {\n\
        include       mime.types;\n\
        default_type  application/octet-stream;\n\
        server {\n\
            listen 8888;\n\
            server_name localhost;\n\
            location ~/group([0-9])/M00 {\n\
                ngx_fastdfs_module;\n\
            }\n\
        }\n\
    }">/usr/local/nginx/conf/nginx.conf \
    && ln -s /usr/local/nginx/sbin/nginx /usr/bin/

#清理文件
RUN rm -rf ${TOOLS}/*

#暴露端口
EXPOSE 22122 23000 8888

#设置卷
VOLUME ["$FASTDFS_BASE_PATH","/etc/fdfs","/usr/local/nginx/conf"] 

#复制配置文件到/etc/fdfs/
COPY conf/*.* /etc/fdfs/
#复制start.sh到/usr/bin/
COPY start.sh /usr/bin/

#授权start.sh
RUN chmod 777 /usr/bin/start.sh

WORKDIR ${FASTDFS_BASE_PATH}

ENTRYPOINT ["/usr/bin/start.sh"]
CMD ["tracker"]

