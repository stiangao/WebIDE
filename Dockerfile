FROM mratin/maven-node-alpine

USER root

RUN apk --update --upgrade add zsh

# Add user `coding`
RUN adduser -D -h /home/coding -s /bin/zsh coding \
	&& echo "coding:coding" | chpasswd 
# Install git
RUN apk --update add curl bash git perl

ENV HOME /home/coding
ENV SHELL /bin/zsh
ENV TERM xterm

ADD . /opt/coding/WebIDE

# Install oh-my-zsh
RUN git clone git://github.com/robbyrussell/oh-my-zsh.git ~/.oh-my-zsh \
	&& cp ~/.oh-my-zsh/templates/zshrc.zsh-template ~/.zshrc

RUN chown -R coding /opt/coding/WebIDE && mkdir $HOME/.m2 \
    && cd /opt/coding/WebIDE/frontend  \
    && npm install && npm run build \
    && cd /opt/coding/WebIDE/frontend-webjars \
    && mvn clean install \
    && cd /opt/coding/WebIDE/backend \
    && mvn clean package -Dmaven.test.skip=true \
    && cp /opt/coding/WebIDE/backend/target/ide-backend.jar /opt/coding/ \
    && mkdir /opt/coding/lib \
    && cp -f /opt/coding/WebIDE/backend/src/main/resources/lib/* /opt/coding/lib/ \
    && rm -fr /opt/coding/WebIDE \
    && rm -fr $HOME/.m2

ENV CODING_IDE_HOME /home/coding/coding-ide-home

EXPOSE 8080

USER coding

CMD ["java", "-jar", "/opt/coding/ide-backend.jar", "--PTY_LIB_FOLDER=/opt/coding/lib"]
