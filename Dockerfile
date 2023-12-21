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
RUN useradd -m -G wheel -g users builder -s /bin/bash && \
    echo "builder ALL=(ALL) NOPASSWD: ALL" >> /etc/sudoers && \
    echo "root ALL=(ALL) NOPASSWD: ALL" >> /etc/sudoers

# Change to user builder
USER builder

WORKDIR /tmp

COPY --chown=builder:users . .

# Run entrypoint
ENTRYPOINT ["./build-packages.sh"]

CMD [ "./build-packages.sh" ]
