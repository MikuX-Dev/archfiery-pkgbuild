FROM archlinux

# Setup mirrors
RUN printf "[multilib]\nInclude = /etc/pacman.d/mirrorlist\n" \
        >> "$path/etc/pacman.conf" && \
    sed -i 's/^#Server/Server/' /etc/pacman.d/mirrorlist

RUN pacman-key --init && \
    pacman-key --populate

# Setup build dependencies
RUN pacman --noconfirm --noprogressbar --needed -Syy base-devel

# Add builder User
RUN useradd -rm -s /bin/bash -g users -G wheel builder

# Change to user builder
USER builder
WORKDIR /home/builder/src

COPY . .
RUN chown -R builder:users /home/builder/src

# Run entrypoint
ENTRYPOINT ["./build-packages.sh"]

CMD [ "./build-packages.sh" ]
