FROM archlinux:latest

RUN pacman-key --init && \
    pacman --noconfirm --noprogressbar --needed -Syy archlinux-keyring && \
    pacman -Sy make devtools

RUN mkdir -p /startdir /build-chroot && \
    groupadd -g 1000 user && \
    useradd -m -d /build-chroot -u 1000 -g 1000 -G wheel -s /bin/bash user && \
    chown -R user:user /startdir /build-chroot && \
    echo 'user ALL=(ALL) NOPASSWD:ALL' >> /etc/sudoers
    # useradd -r -m -s /bin/bash -G wheel user && \
    # sed -i 's/^# %wheel ALL=(ALL:ALL) ALL/%wheel ALL=(ALL:ALL) ALL/g' /etc/sudoers

RUN chown -R user:user *

ENTRYPOINT [ "./pkg-local.sh" ]
CMD [ "sh", "./pkg-local.sh" ]