FROM fedora:25

MAINTAINER John Koelndorfer <jkoelndorfer@gmail.com>

# Reinstall any already-installed software so that we get its documentation.
#
# Update any base packages in our image.
RUN dnf -y reinstall '*' && dnf -y update

# Install the absolute basics.
RUN dnf -y install openssh openssh-clients openssh-server sudo supervisor

# Install all the nice user applications.
#
# TODO: Make the list of packages a build arg once Ansible 2.2 releases
RUN dnf -y install \
        ansible \
        bind-utils \
        fedora-packager \
        git \
        hostname \
        man \
        man-pages \
        mosh \
        neovim \
        net-tools \
        nmap \
        nmap-ncat \
        procps-ng \
        python2-neovim \
        python3-neovim \
        ruby \
        texlive-lastpage \
        texlive-scheme-basic \
        tmux \
        vim-enhanced \
        weechat \
        zsh \
        && \
    dnf clean all && \
    rm -rf /var/cache/dnf/*

RUN pip3 install hangups

# Fix sshd settings.
RUN sed -i -e 's/^#PermitRootLogin yes/PermitRootLogin no/'               /etc/ssh/sshd_config && \
    sed -i -e 's/^#GSSAPIAuthentication yes/GSSAPIAuthentication no/'     /etc/ssh/sshd_config && \
    sed -i -e 's/^#PasswordAuthentication yes/PasswordAuthentication no/' /etc/ssh/sshd_config && \
    sed -i -e 's!^HostKey /etc/ssh!HostKey /etc/ssh/host_keys!'           /etc/ssh/sshd_config

# sshd host keys are generated at boot time if they don't already exist.
RUN mkdir /etc/ssh/host_keys

COPY build/wheel-passwordless-sudo /etc/sudoers.d/wheel-passwordless-sudo
COPY app/entrypoint.sh /app/entrypoint.sh
COPY app/supervisord.ini /etc/supervisord.d/supervisord.ini

# This needs to be removed before login via ssh will be allowed.
RUN rm -f /var/run/nologin

EXPOSE 22
EXPOSE 60000-61000/udp

VOLUME ["/home", "/etc/ssh/host_keys"]

CMD ["/app/entrypoint.sh"]
