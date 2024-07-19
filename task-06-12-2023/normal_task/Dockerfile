FROM ubuntu:20.04 

ENV TZ=Europe/Moscow
RUN ls -snf /usr/share/zoneinfo/$TZ > /etc/localtime && echo $TZ 

RUN apt update && \
    apt install -y python3-pipansible git && \
    pip3 install ansible --upgrade && \
    apt clean && \
    rm -rf /var/lib/apt/lists/* 

CMD ["/bin/bash"]