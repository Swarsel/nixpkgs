{
  lib,
  stdenv,
  curl,
  fetchgit,
  goocanvas_1,
  gtk2,
  json-glib,
  libmicrohttpd,
  libusb1,
  libwebsockets,
  libxml2,
  libzip,
  openssl,
  php,
  pkg-config,
  qrencode,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "bellepoule";
  version = "5.7";

  src =
    (fetchgit {
      url = "https://git.launchpad.net/bellepoule";
      # No tag available on launchpad for this version
      rev = "06516d698fde9662d95cf6a8758eb1fbcc89e983";
      hash = "sha256-9bbFzi9JPryJK2zv4O1TUDaeoB9GVV7LRNn6Xl8lajg=";
    }).overrideAttrs
      (oldAttrs: {
        env = oldAttrs.env or { } // {
          GIT_CONFIG_COUNT = 1;
          GIT_CONFIG_KEY_0 = "url.https://github.com/.insteadOf";
          GIT_CONFIG_VALUE_0 = "git@github.com:";
        };
      });

  # Use system php
  # Disable git soft depend
  # Disable dch changelog generation
  # FixUp `install` phase output
  postPatch = ''
    substituteInPlace ./sources/common/network/web_server.cpp --replace-fail "php7.4" "${php}/bin/php"
    substituteInPlace ./build/BellePoule/debian/bellepoule.desktop.template --replace-fail "/usr" "$out"
    substituteInPlace ./build/BellePoule/Makefile \
      --replace-fail "git" "#git" \
      --replace-fail "dch" "echo Ignoring: dch" \
      --replace-fail "/usr" ""
  '';

  nativeBuildInputs = [ pkg-config ];

  buildInputs = [
    gtk2
    libxml2
    curl
    libmicrohttpd
    goocanvas_1
    qrencode
    openssl
    json-glib
    libzip
    libusb1
    libwebsockets
  ];

  makeFlags = [
    "HOME=$(pwd)"
    "DISTRIB=nixos"
    "V=1"
    "DESTDIR=$(out)"
  ];

  # Prepare release directory for buildPhase
  preBuild = ''
    cd build/BellePoule
    make HOME=$(pwd) DISTRIB=nixos V=1 package
    cd ./Perso/PPA/${finalAttrs.pname}/${finalAttrs.pname}_${finalAttrs.version}
  '';

  meta = {
    description = "Fencing tournaments management software";
    homepage = "http://betton.escrime.free.fr";
    changelog = "https://git.launchpad.net/bellepoule/log/?h=${finalAttrs.version}";
    license = lib.licenses.gpl3Only;
    maintainers = with lib.maintainers; [ tgi74 ];
    platforms = lib.platforms.linux;
    mainProgram = "bellepoule-supervisor";
  };
})
