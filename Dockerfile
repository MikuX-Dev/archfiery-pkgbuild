# Use the Arch Linux base image with development tools
FROM mikuxdev/pkg-aur:latest

RUN sudo pacman -Syy
# RUN sudo sed -i '/E_ROOT/d' /usr/bin/makepkg

# COPY pkg-aur.sh /home/builder/pkg-aur.sh

RUN sudo chown -R builder:builder /home/builder/
RUN chmod +x pkg-aur.sh
RUN sudo chown -R builder:builder /home/builder/

ENTRYPOINT ["./pkg-aur.sh"]