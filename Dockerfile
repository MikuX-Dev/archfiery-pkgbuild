# Use the Arch Linux base image with development tools
FROM marvin0815/aurbuild

RUN pacman-key --init

RUN \
if grep -q "\[multilib\]" /etc/pacman.conf; then \
  sed -i '/^\[multilib\]/,/Include = \/etc\/pacman.d\/mirrorlist/ s/^#//' /etc/pacman.conf; \
else \
  echo -e "[multilib]\nInclude = /etc/pacman.d/mirrorlist" | tee -a /etc/pacman.conf; \
fi

RUN sed -i "s/#en_US.UTF-8 UTF-8/en_US.UTF-8 UTF-8/g" /etc/locale.gen && \
    locale-gen && \
    echo "LANG=en_US.UTF-8" > /etc/locale.conf && \
    echo 'KEYMAP=us' > /etc/vconsole.conf

# Update the system and install essential packages
RUN pacman -Syy --noconfirm --quiet --needed archlinux-keyring

RUN pacman -Syyu --noconfirm --quiet --needed reflector rsync curl wget base-devel devtools sudo git namcap fakeroot audit grep diffutils && \
    reflector --latest 21 -f 21 -n 21 --age 21 --protocol https --download-timeout 55 --sort rate --save /etc/pacman.d/mirrorlist && \
    pacman -Syy

# chown user
RUN chown -R builder:builder /huser/

USER builder
WORKDIR /huser

ENV PATH=/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin:/usr/bin/core_perl

# chown user
RUN sudo chown -R builder:builder /huser/

# install yay
RUN \
    cd /huser/ && \
    curl -O -s https://aur.archlinux.org/cgit/aur.git/snapshot/yay-bin.tar.gz && \
    tar xf yay-bin.tar.gz && \
    cd yay-bin && makepkg -is --skippgpcheck --noconfirm && cd .. && \
    rm -rf yay-bin && rm yay-bin.tar.gz

RUN yay -S aurutils

RUN sudo pacman -Scc --noconfirm

# RUN su -m builder -c "./pkg-aur.sh"
ENTRYPOINT [ "./pkg-aur.sh" ]