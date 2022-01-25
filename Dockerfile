ARG ALPINE_VERSION=latest
FROM alpine:${ALPINE_VERSION} AS base

ARG USER=anvil
ENV USER=${USER}
ENV TZ=America/New_York
WORKDIR /app/

RUN 

RUN apk --no-cache add \
  bash \
  ca-certificates \
  curl \
  make \
  openssl \
  openssh-client \
  sudo \
  tzdata \
  zsh \
  zsh-autosuggestions \
  zsh-syntax-highlighting && \
  rm -rf /var/cache/apk/* 

# setup local timezone
RUN \
  adduser --disabled-password --home /home/$USER --shell /bin/zsh $USER && \
  chown -R ${USER}:${USER} /home/${USER} && \
  ln -snf /etc/localtime /usr/share/zoneinfo/${TZ} && echo ${TZ} > /etc/timezone 

# install oh-my-zsh
RUN curl -sLO "https://raw.github.com/robbyrussell/oh-my-zsh/master/tools/install.sh" | bash -s 

# install kubectl
RUN curl -sLO "https://storage.googleapis.com/kubernetes-release/release/$(curl -s https://storage.googleapis.com/kubernetes-release/release/stable.txt)/bin/linux/amd64/kubectl" && \
  chmod +x ./kubectl && mv ./kubectl /usr/local/bin/kubectl 

# install k3sup
RUN curl -L "https://get.k3sup.dev" | bash -s

# install helm
RUN curl -L https://raw.githubusercontent.com/helm/helm/master/scripts/get-helm-3 | bash -s

#ADD https://gist.githubusercontent.com/ilude/e2342829a97c3c3d3da5f9c73976c4ec/raw/gitconfig /home/$USER/.gitconfig

COPY config/*.sh /usr/local/bin/
RUN chmod +x /usr/local/bin/*.sh

#COPY config/zshrc /home/$USER/.zshrc

#USER ${USER}:${USER}

ENTRYPOINT [ "docker-entrypoint.sh" ]
CMD ["bash"]