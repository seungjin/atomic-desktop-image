ARG FEDORA_MAJOR_VERSION=39

FROM quay.io/fedora-ostree-desktops/silverblue:${FEDORA_MAJOR_VERSION}

RUN rpm-ostree install \
    https://mirrors.rpmfusion.org/free/fedora/rpmfusion-free-release-$(rpm -E %fedora).noarch.rpm \
    https://mirrors.rpmfusion.org/nonfree/fedora/rpmfusion-nonfree-release-$(rpm -E %fedora).noarch.rpm

RUN mkdir -p /var/lib && ln -s /usr/lib/alternatives /var/lib/alternatives

COPY pkgs /tmp/pkgs
RUN rpm-ostree install $(cat /tmp/pkgs/base)
RUN rpm-ostree install $(cat /tmp/pkgs/virt)
RUN rpm-ostree install $(cat /tmp/pkgs/docker)
RUN rpm-ostree install $(cat /tmp/pkgs/nvidia)

RUN sed -i 's/#AutomaticUpdatePolicy.*/AutomaticUpdatePolicy=stage/' /etc/rpm-ostreed.conf && \
    systemctl enable rpm-ostreed-automatic.timer

# nvidia driver 
#nvidia non-free driver
#RUN rpm-ostree install kmod-nvidia xorg-x11-drv-nvidia 
#RUN  rpm-ostree kargs --append=rd.driver.blacklist=nouveau \
#    --append=modprobe.blacklist=nouveau \
#    --append=nvidia-drm.modeset=1
#RUN rm -fr /var/log/akmods/akmods.log

#RUN systemctl enable vnstat.service
#RUN systemctl enable sshd.service
#RUN semanage port -a -t ssh_port_t -p tcp 432
#RUN systemctl enable firewalld 
#RUN firewall-cmd --permanent --zone=public --add-port=432/tcp

COPY usr /usr
RUN mkdir /usr/lib/vagrant

#RUN mv /usr/share/ibus/component/hangul.xml /usr/share/ibus/component/hangul.xml.original
#COPY usr/share/ibus/component/hangul.xml /usr/share/ibus/component/hangul.xml 

RUN rm -fr /var/lib

RUN rpm-ostree cleanup -m && ostree container commit


