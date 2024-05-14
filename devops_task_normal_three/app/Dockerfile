FROM python:alpine  

# set up work directory 

WORKDIR /app 

# set up ownership and copy django project to docker work directory

COPY . . 

# install requirements 
RUN pip3 manage.py migrate

# set up port
EXPOSE 8000 


# start dajngo app 

CMD ["python", "manage.py", "runserver", "0.0.0.0:8000"]