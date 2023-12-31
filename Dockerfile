# Use the Arch Linux base image with development tools
FROM mikuxdev/pkg-aur:latest

RUN chmod u+x .*

# RUN su -m builder -c "./pkg-aur.sh"
ENTRYPOINT [ "./pkg-aur.sh" ]
