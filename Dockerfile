# FROM python:alpine
#
# COPY . ./app
#
# WORKDIR /app
#
# COPY requirements.txt /requirements.txt
#
# RUN pip install -r /requirements.txt;
#
# ENTRYPOINT [ "python" ]
#
# CMD ["main.py"]




#FROM python:3.11.0a7-alpine3.15 #  Error: Please make sure the libxml2 and libxslt development packages are installed.
#FROM python:3.6
FROM python:alpine

COPY . /app

#RUN apk add --no-cache --virtual .build-deps build-base
#RUN apk add --no-cache openldap-dev libxml2-dev libxslt-dev
#RUN pip install --no-cache-dir lxml python-ldap
# RUN apk del .build-deps 

#RUN apk add --update --no-cache g++ gcc libxslt-dev libxml2 py-lxml

# RUN apk add --update --no-cache g++ gcc libxslt-dev
# RUN pip install lxml

WORKDIR /app

RUN pip install -r requirements.txt

# EXPOSE 5050

#ENTRYPOINT [ "python" ]

# CMD ["python3", "-u", "main.py"]
