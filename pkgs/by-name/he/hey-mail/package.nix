{
  lib,
  stdenv,
  fetchurl,
  alsa-lib,
  at-spi2-atk,
  at-spi2-core,
  atk,
  autoPatchelfHook,
  c-ares,
  cairo,
  cups,
  dbus,
  expat,
  ffmpeg,
  gdk-pixbuf,
  glib,
  gtk3-x11,
  http-parser,
  imagemagick,
  libGL,
  libappindicator-gtk2,
  libappindicator-gtk3,
  libdrm,
  libevent,
  libgbm,
  libnotify,
  libvpx,
  libx11,
  libxcb,
  libxcomposite,
  libxcursor,
  libxdamage,
  libxext,
  libxfixes,
  libxi,
  libxkbcommon,
  libxrandr,
  libxrender,
  libxslt,
  libxtst,
  makeWrapper,
  nspr,
  nss,
  pango,
  squashfsTools,
  systemd,
  wrapGAppsHook3,
  writeScript,
}:
let
  deps = [
    c-ares
    gtk3-x11
    glib
    libevent
    libdrm
    libvpx
    libxslt
    libnotify
    libappindicator-gtk2
    libappindicator-gtk3
    libxkbcommon
    libGL
    atk
    libgbm
    cups
    systemd
    alsa-lib
    at-spi2-atk
    at-spi2-core
    gdk-pixbuf
    pango
    cairo
    libxcb
    libx11
    libxcomposite
    libxcursor
    libxdamage
    libxext
    libxfixes
    libxi
    libxrender
    libxtst
    libxrandr
    ffmpeg
    http-parser
    nss
    nspr
    dbus
    expat
    stdenv.cc.cc
  ];
in
stdenv.mkDerivation (finalAttrs: {
  pname = "hey-mail";
  version = "1.3.3";

  src = fetchurl {
    url = "https://api.snapcraft.io/api/v1/snaps/download/lfWUNpR7PrPGsDfuxIhVxbj0wZHoH7bK_${finalAttrs.rev}.snap";
    hash = "sha512-0KhmZ1xkEPuuzukeKbWW7jeNh2TOINMnOtuwpZQIM7sgDhCSl2DEZnguEKY2DvGNTTQxVWSZcuU/KSSblqIE4Q==";
  };

  nativeBuildInputs = [
    squashfsTools
    makeWrapper
    autoPatchelfHook
    wrapGAppsHook3
    imagemagick
  ];

  buildInputs = deps;

  installPhase = ''
    runHook preInstall

    mkdir -p $out/lib $out/share/applications/ $out/share/icons/ $out/bin
    mv ./* $out/

    ln -s $out/meta/snap.yaml $out/snap.yaml

    librarypath="${lib.makeLibraryPath deps}"

    wrapProgram $out/hey-mail \
      --prefix LD_LIBRARY_PATH : "$librarypath"

    ln -s $out/hey-mail $out/bin/hey-mail

    # fix icon line in the desktop file
    sed -i "s:^Icon=.*:Icon=hey-mail:" "$out/meta/gui/hey-mail.desktop"

    # Copy desktop file
    cp "$out/meta/gui/hey-mail.desktop" "$out/share/applications/"

    runHook postInstall
  '';

  postInstall = ''
    for i in 16 24 32 48 64 96 128 256 512; do
      mkdir -p $out/share/icons/hicolor/''${i}x''${i}/apps
      magick $out/meta/gui/icon.png -background none -resize ''${i}x''${i} $out/share/icons/hicolor/''${i}x''${i}/apps/hey-mail.png
    done
  '';

  rev = "31";

  unpackPhase = ''
    runHook preUnpack
    unsquashfs "$src"
    cd squashfs-root
    runHook postUnpack
  '';

  passthru.updateScript = writeScript "update-hey-mail" ''
    #!/usr/bin/env nix-shell
    #!nix-shell -i bash -p common-updater-scripts curl jq

    set -eu -o pipefail

    data=$(curl -H 'X-Ubuntu-Series: 16' \
    'https://api.snapcraft.io/api/v1/snaps/details/hey-mail?fields=download_sha512,revision,version')

    version=$(jq -r .version <<<"$data")

    if [[ "x$UPDATE_NIX_OLD_VERSION" != "x$version" ]]; then

        revision=$(jq -r .revision <<<"$data")
        hash=$(nix --extra-experimental-features nix-command hash to-sri "sha512:$(jq -r .download_sha512 <<<"$data")")

        update-source-version "$UPDATE_NIX_ATTR_PATH" "$version" "$hash"
        update-source-version --ignore-same-hash --version-key=rev "$UPDATE_NIX_ATTR_PATH" "$revision" "$hash"

    fi
  '';

  meta = {
    description = "Desktop client for HEY email";
    homepage = "https://hey.com";
    license = lib.licenses.unfree;
    maintainers = [ lib.maintainers.peret ];
    platforms = [ "x86_64-linux" ];
    mainProgram = "hey-mail";
  };
})
