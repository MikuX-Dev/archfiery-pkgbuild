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
RUN useradd --disabled-password -rm -d /home/builder/ -s /bin/bash -g users -G wheel builder

# Change to user builder
USER builder
WORKDIR /home/builder/src

RUN chown -R builder:users /home/builder/src

# COPY --chown=builder:users . .

# Run entrypoint
ENTRYPOINT ["./build-packages.sh"]

CMD [ "./build-packages.sh" ]
