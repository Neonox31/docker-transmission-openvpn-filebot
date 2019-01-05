FROM haugene/transmission-openvpn:latest

RUN mkdir -p /downloads

ENV FILEBOT_VERSION 4.8.5
ENV JAVA_OPTS "-Dsun.jnu.encoding=UTF-8 -Dfile.encoding=UTF-8 -DuseGVFS=false -Djava.net.useSystemProxies=false -Dapplication.deployment=docker -Dapplication.dir=/data -Duser.home=/data -Djava.io.tmpdir=/data/tmp -Djava.util.prefs.PreferencesFactory=net.filebot.util.prefs.FilePreferencesFactory -Dnet.filebot.util.prefs.file=/data/prefs.properties"

RUN apt-get update && DEBIAN_FRONTEND=noninteractive apt-get install -y apt-transport-https locales
RUN sed -i -e 's/# en_US.UTF-8 UTF-8/en_US.UTF-8 UTF-8/' /etc/locale.gen && \
    dpkg-reconfigure --frontend=noninteractive locales && \
    update-locale LANG=en_US.UTF-8

# Install java 11
RUN add-apt-repository ppa:openjdk-r/ppa -y \
    && apt-get update \
    && apt-get install -y --no-install-recommends openjdk-11-jre \
    && ln -s java-11-openjdk-amd64 /usr/lib/jvm/default-jvm

# Install filebot
RUN curl -fsSL https://raw.githubusercontent.com/filebot/plugins/master/gpg/maintainer.pub | apt-key add \
 && echo "deb https://get.filebot.net/deb/ stable universal" > /etc/apt/sources.list.d/filebot.list \
 && apt-get update \
 && apt-get install -y --no-install-recommends filebot libjna-jni libmediainfo0v5 libchromaprint-tools p7zip-full p7zip-rar curl file inotify-tools \
 && rm -rvf /var/lib/apt/lists/*

VOLUME /output

# Run openvpn script
CMD ["dumb-init", "/etc/openvpn/start.sh"]
