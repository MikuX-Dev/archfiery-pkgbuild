FROM mikuxdev/archiso:latest

RUN sudo pacman-key --init && \
    sudo pacman-key --populate

# Setup build dependencies
RUN sudo pacman --noconfirm --noprogressbar --needed -Syy base-devel

# # Add builder User
# RUN useradd -rm -s /bin/bash -g users -G wheel builder

# # Change to user builder
# USER builder
# COPY . .
WORKDIR /home/builder/src

# Run entrypoint
ENTRYPOINT [ "makepkg" ]

CMD [ "-s" "-f" "--noconfirm" "--needed" "--noprogressbar" ]
