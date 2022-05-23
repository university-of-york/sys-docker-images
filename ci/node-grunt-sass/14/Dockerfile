FROM library/node:14-bullseye

ENV DEBIAN_FRONTEND noninteractive

RUN apt-get update && apt-get install -y --no-install-recommends apt-utils
RUN apt-get install -y ruby ruby-dev locales

RUN sed -i '/en_US.UTF-8/s/^# //g' /etc/locale.gen && \
    locale-gen
ENV LANG en_US.UTF-8  
ENV LANGUAGE en_US:en  
ENV LC_ALL en_US.UTF-8     

RUN npm install -g grunt-cli
RUN gem install sass

# Define working directory.
WORKDIR /data

ENV DEBIAN_FRONTEND newt

# Define default command.
CMD ["bash"]

