## Build image


````
docker build  -t edwin/lor-alpine  .
````


## Create your app

```
docker run -v "$PWD":/tmp --rm  edwin/lor-alpine lord new  $your_app
```

for example
```
docker run -v "$PWD":/tmp --rm  edwin/lor-alpine lord new lor-example
````
Here $your_app should be the name of your app, such as 'lor-example' "openresty-china".

## Start the server

```
docker run -v "$your_app_dir":/tmp -d -p 8888:8888 edwin/lor-alpine
```

for example 
```
docker run -v "/tmp/lor-example":/tmp -d -p 8888:8888 edwin/lor-alpine
```
Here $your_app_dir should be where your app locates on, such as '/tmp/lor-example'.

###  lor-example
if you want to try  [lor-example](https://github.com/lorlabs/lor-example), assume you put the following code in directory "/tmp"

git clone https://github.com/lorlabs/lor-example

docker run -v "/tmp/lor-example":/tmp -d -p 8888:8888 edwin/lor-alpine


### openresty-china

if you want to try [openresty-china](https://github.com/sumory/openresty-china), assume you put the following code in directory "/tmp"

git clone https://github.com/sumory/openresty-china

prerequirements
- you need a working mysql,here i use mysql container ,more info see [here](https://github.com/wangxian/alpine-mysql)
- modify setting in app/config/config.lua,conf/nginx-dev.conf,conf/nginx-prod.conf


docker run -v "/tmp/openresty-china":/tmp -d -p 8888:8888 edwin/lor-alpine
