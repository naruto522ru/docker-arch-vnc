FROM archlinux
## Base
RUN sed -i 's/SigLevel.*/SigLevel = Never/' /etc/pacman.conf && sed -i 's/#ParallelDownloads = 5/ParallelDownloads = 10/' /etc/pacman.conf && sed -i 's/#Color/Color/' /etc/pacman.conf && sed -i 's/CheckSpace/#CheckSpace/' /etc/pacman.conf && rm -rv /etc/pacman.d/gnupg/ && pacman -Syyu reflector archlinux-keyring wget --noconfirm  && pacman-key --init && pacman-key --populate archlinux && reflector --ipv4 @/etc/xdg/reflector/reflector.conf && pacman -Syu $(pacman -Qnq) --noconfirm  && pacman --noconfirm -S man-db base-devel base nano unzip git bash bash-completion mc openssh zip htop python-pip pacutils pacman-contrib sudo mtr strace gnu-netcat iftop bind cmake axel && useradd -m -g users -G log,systemd-journal,power,daemon -s /bin/bash docker_user && echo "docker_user ALL=(ALL) NOPASSWD:ALL" >> /etc/sudoers && cd /home/docker_user/ && git clone https://aur.archlinux.org/yay.git && chown -R docker_user:users ./yay && cd yay && rm -v /etc/makepkg.conf && wget http://sprunge.us/m3atyz && mv ./m3atyz /etc/makepkg.conf && sudo -u docker_user /usr/bin/makepkg -scCfi --noconfirm && cd ../ && rm -rf ./yay/ && sudo -u docker_user /usr/bin/yay -S zsh zsh-systemd-git zsh-sudo-git zsh-completions zsh-you-should-use zsh-autosuggestions zsh-autopair-git zsh-syntax-highlighting icdiff beautysh nano-syntax-highlighting-git downgrade --noconfirm && sudo -u docker_user /usr/bin/yay -Sc --noconfirm && chsh -s /bin/zsh root && chsh -s /bin/zsh docker_user && sudo -u docker_user /usr/bin/wget http://sprunge.us/6g1UXG -P /home/docker_user/ && sudo -u docker_user /usr/bin/mv /home/docker_user/6g1UXG /home/docker_user/.zshrc && echo "include /usr/share/nano-syntax-highlighting/*.nanorc" > /etc/nanorc && ln -sv /home/docker_user/.zshrc /root/.zshrc && rm -f /var/cache/pacman/pkg/*.pkg.tar.* && wget https://gitlab.archlinux.org/archlinux/packaging/packages/pacman/-/raw/main/pacman.conf -O ./pacman.conf && mv ./pacman.conf /etc/pacman.conf && sed -i 's/#ParallelDownloads = 5/ParallelDownloads = 10/' /etc/pacman.conf && sed -i 's/#Color/Color/' /etc/pacman.conf && sed -i 's/CheckSpace/#CheckSpace/' /etc/pacman.conf && passwd -d docker_user
# Install Android-NDK (optional)
ARG NDK_VERSION=r24
RUN axel -4 https://dl.google.com/android/repository/android-ndk-${NDK_VERSION}-linux.zip && mv ./android-ndk-${NDK_VERSION}-linux.zip /opt/ && cd /opt && unzip ./android-ndk-${NDK_VERSION}-linux.zip && rm -f /opt/*.zip
##GUI
RUN pacman -S --noconfirm xorg-server tigervnc which python-setuptools ttf-dejavu
# DE install
#LXQT
#RUN pacman -S --noconfirm lxqt breeze-icons oxygen-icons
#LXDE
RUN pacman -S --noconfirm lxde
# Terminal's
RUN pacman -S --noconfirm alacritty
# Browser's
RUN pacman -S --noconfirm firefox firefox-i18n-ru firefox-ublock-origin
#RUN sudo -u docker_user /usr/bin/yay -S palemoon-bin palemoon-i18n-ru --noconfirm
# Install AUR package (EXEMPLE)
#RUN sudo -u docker_user /usr/bin/yay -S PKG1 PKG2 ... --noconfirm
# Clean cache package (AUR)
#RUN sudo -u docker_user /usr/bin/yay -Sc --noconfirm
# Clean cache package
RUN rm -f /var/cache/pacman/pkg/*.pkg.tar.* && rm -rf /home/docker_user/.cache/yay/*
# Remove Temp Package
#RUN pacman -Rcns reflector --noconfirm
# Generate locales
RUN rm -f /usr/share/i18n/locales/* && pacman -S glibc --noconfirm --overwrite=* && echo -e "en_US.UTF-8 UTF-8\nru_RU.UTF-8 UTF-8" > /etc/locale.gen && sleep 2s && locale-gen
# Set locale
#RUN echo 'LANG="ru_RU.UTF-8"' > /etc/locale.conf
# Compiling mdig-bolvan
RUN wget -nv https://raw.githubusercontent.com/bol-van/zapret/master/mdig/Makefile -P /tmp/ && wget -nv https://raw.githubusercontent.com/bol-van/zapret/master/mdig/mdig.c -P /tmp/ && mv /tmp/Makefile /tmp/Makefile.mdig && cd /tmp/ && make -f Makefile.mdig && mv mdig /usr/local/bin/mdig-bolvan && chmod 755 /usr/local/bin/mdig-bolvan && rm /tmp/mdig.c* &>/dev/null && rm /tmp/Makefile* &>/dev/null
# copy directory contents to /scripts
COPY ./scripts /scripts

WORKDIR /root

EXPOSE 5900 6080

CMD [ "/scripts/start.sh" ]
