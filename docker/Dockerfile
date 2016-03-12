FROM alpine:3.3

ENV LUA_SUFFIX=jit-2.1.0-beta1 \
    LUAJIT_VERSION=2.1 \
    NGINX_PREFIX=/opt/openresty/nginx \
    OPENRESTY_PREFIX=/opt/openresty \
    OPENRESTY_SRC_SHA1=1a2029e1c854b6ac788b4d734dd6b5c53a3987ff \
    OPENRESTY_VERSION=1.9.7.3 \
    VAR_PREFIX=/var/nginx  \
    LOR_VERSION=V0.0.9   \
    LOR_PREFIX=/usr/local/lor \
	PYTHON_VERSION=2.7.11-r3 \
	PY_PIP_VERSION=7.1.2-r0 \
	SUPERVISOR_VERSION=3.2.0


RUN sed -i 's/dl-cdn.alpinelinux.org/mirrors.ustc.edu.cn/' /etc/apk/repositories

## install openresty with luajit 
RUN set -ex \
  && apk --no-cache add --virtual .openresty-build-dependencies \
    curl \
    make \
    musl-dev \
    gcc \
    ncurses-dev \
    openssl-dev \
    pcre-dev \
    perl \
    readline-dev \
    zlib-dev \
  \
  && curl -fsSL http://openresty.org/download/openresty-${OPENRESTY_VERSION}.tar.gz -o /tmp/openresty.tar.gz \
  \
  && cd /tmp \
  && echo "${OPENRESTY_SRC_SHA1} *openresty.tar.gz" | sha1sum -c - \
  && tar -xzf openresty.tar.gz \
  \
  && cd openresty-* \
  && readonly NPROC=$(grep -c ^processor /proc/cpuinfo 2>/dev/null || 1) \
  && ./configure \
    --prefix=${OPENRESTY_PREFIX} \
    --http-client-body-temp-path=${VAR_PREFIX}/client_body_temp \
    --http-proxy-temp-path=${VAR_PREFIX}/proxy_temp \
    --http-log-path=${VAR_PREFIX}/access.log \
    --error-log-path=${VAR_PREFIX}/error.log \
    --pid-path=${VAR_PREFIX}/nginx.pid \
    --lock-path=${VAR_PREFIX}/nginx.lock \
    --with-luajit \
    --with-pcre-jit \
    --with-ipv6 \
    --with-http_ssl_module \
    --without-http_ssi_module \
    --with-http_realip_module \
    --without-http_scgi_module \
    --without-http_uwsgi_module \
    --without-http_userid_module \
    -j${NPROC} \
  && make -j${NPROC} \
  && make install \
  \
  && rm -rf /tmp/openresty* \
  && apk del .openresty-build-dependencies

RUN ln -sf ${NGINX_PREFIX}/sbin/nginx /usr/local/bin/nginx \
  && ln -sf ${NGINX_PREFIX}/sbin/nginx /usr/local/bin/openresty \
  && ln -sf ${OPENRESTY_PREFIX}/bin/resty /usr/local/bin/resty \
  && ln -sf ${OPENRESTY_PREFIX}/luajit/bin/luajit-* ${OPENRESTY_PREFIX}/luajit/bin/lua \
  && ln -sf ${OPENRESTY_PREFIX}/luajit/bin/luajit-* /usr/local/bin/lua \
  && ln -sf /opt/openresty/luajit/bin/luajit /usr/bin/luajit

RUN apk --no-cache add \
    libgcc \
    libpcrecpp \
    libpcre16 \
    libpcre32 \
    libssl1.0 \
    libstdc++ \
    openssl \
    pcre
	
	

RUN apk update && apk add -u python=$PYTHON_VERSION py-pip=$PY_PIP_VERSION
RUN pip install supervisor==$SUPERVISOR_VERSION

RUN apk update \
  && apk add --virtual .lor-build-deps  \
  	 git \
  && cd /tmp \
  && git clone https://github.com/sumory/lor  \
  && cd lor \
  && sh install.sh \
  && rm -rf /tmp/lor \
  && adduser -D -g '' -u 1000 nginx



RUN apk --update add libuuid && rm -f /var/cache/apk/*  \
&& ln -s /usr/lib/libuuid.so $OPENRESTY_PREFIX/lualib



ADD ./supervisord.conf /etc/
RUN mkdir -p /var/log/supervisor 
WORKDIR /tmp


EXPOSE 8888
CMD ["/usr/bin/supervisord"]
