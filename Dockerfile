FROM ubuntu:20.04
RUN apt-get -y update
RUN ln -fs /usr/share/zoneinfo/UTC /etc/localtime
RUN apt-get -y install postgresql-12
RUN echo host all all 0.0.0.0/0 trust >/etc/postgresql/12/main/pg_hba.conf
RUN echo local all all trust >>/etc/postgresql/12/main/pg_hba.conf
RUN apt-get -y install curl
RUN curl -L -o /usr/bin/kubectl "https://dl.k8s.io/release/v1.23.1/bin/linux/amd64/kubectl"
RUN chmod 755 /usr/bin/kubectl
RUN apt-get -y install iputils-ping netcat
