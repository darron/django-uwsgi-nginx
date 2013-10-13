# Django, uWSGI and Nginx in a container

This Dockerfile allows you to build a Docker container with a fairly standard
and speedy setup for Django with uWSGI and Nginx.

uWSGI from a number of benchmarks has shown to be the fastest server 
for python applications and allows lots of flexibility.

Nginx has become the standard for serving up web applications and has the 
additional benefit that it can talk to uWSGI using the uWSGI protocol, further
elinimating overhead. 

Most of this setup comes from the excellent tutorial on 
https://uwsgi.readthedocs.org/en/latest/tutorials/Django_and_nginx.html

Feel free to clone this and modify it to your liking. And feel free to 
contribute patches.

### Build and run
* docker build -t webapp .
* docker run -d webapp

### How to insert your application

The /app directory currently contains a plain vanilla Django application 
you can replace it with your custom application. Just make sure the wsgi.py
contains at least the following lines:

```
import os
os.environ.setdefault("DJANGO_SETTINGS_MODULE", "settings")
from django.core.wsgi import get_wsgi_application
application = get_wsgi_application()
```
