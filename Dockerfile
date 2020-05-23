
FROM ubuntu:16.04

MAINTAINER Leo Du <leo@tianzhui.cloud>

ENV PYTHON_VERSION 3.7.7

# Install required packages and remove the apt packages cache when done.
RUN apt-get update && \
    apt-get upgrade -y && \
    apt-get install -y build-essential zlib1g-dev libncurses5-dev libgdbm-dev libnss3-dev libssl-dev libreadline-dev libffi-dev curl nginx supervisor libmysqlclient-dev && \
    cd /usr/src && \
    curl -SL "https://www.python.org/ftp/python/$PYTHON_VERSION/Python-$PYTHON_VERSION.tgz" -o Python-$PYTHON_VERSION.tgz && \
    tar xzf Python-$PYTHON_VERSION.tgz && \
    cd Python-$PYTHON_VERSION && \
    ./configure --enable-optimizations && \
    make altinstall && \
    ln -s /usr/local/bin/python3.7 /usr/local/bin/python && \
    rm -rf /usr/src/Python-$PYTHON_VERSION.tgz && \
    cd /usr/src && \
    rm -rf /usr/src/Python-$PYTHON_VERSION && \
    python -m pip install --upgrade pip setuptools --no-deps && \
    rm -rf /var/lib/apt/lists/*

# Install uwsgi now because it takes a little while
RUN python -m pip install uwsgi --no-deps

# setup all the configfiles
RUN echo "daemon off;" >> /etc/nginx/nginx.conf
COPY nginx-app.conf /etc/nginx/sites-available/default
COPY supervisor-app.conf /etc/supervisor/conf.d/

# COPY requirements.txt and RUN pip install BEFORE adding the rest of your code, this will cause Docker's caching mechanism
# to prevent re-installing (all your) dependencies when you made a change a line or two in your app.
COPY app/requirements.txt /home/docker/code/app/

RUN python -m pip install mysqlclient==1.4.6 --no-deps
RUN python -m pip install Django==3.0.5 --no-deps
RUN python -m pip install aws-xray-sdk==2.4.3 --no-deps
RUN python -m pip install boto3==1.12.36 --no-deps
RUN python -m pip install botocore==1.15.36 --no-deps
RUN python -m pip install aiobotocore asyncio aiohttp
RUN python -m pip install jsonpickle wrapt
RUN python -m pip install -r /home/docker/code/app/requirements.txt --no-deps

# add (the rest of) our code
COPY . /home/docker/code/

EXPOSE 80
CMD ["supervisord", "-n"]
