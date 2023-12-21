FROM mikuxdev/archiso:latest

RUN pacman-key --init && \
    pacman-key --populate

# Setup build dependencies
RUN pacman --noconfirm --noprogressbar --needed -Syy base-devel

# # Add builder User
# RUN useradd -rm -s /bin/bash -g users -G wheel builder

# # Change to user builder
# USER builder
WORKDIR /home/builder/src

# Run entrypoint
ENTRYPOINT ["./build-packages.sh"]

CMD [ "./build-packages.sh" ]
