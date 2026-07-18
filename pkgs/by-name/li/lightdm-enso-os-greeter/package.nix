{
  lib,
  stdenv,
  fetchFromGitHub,
  at-spi2-core,
  clutter-gtk,
  cmake,
  dbus,
  gdk-pixbuf,
  gtk3,
  libepoxy,
  libgee,
  libpthread-stubs,
  librsvg,
  libx11,
  libxdmcp,
  libxkbcommon,
  libxklavier,
  lightdm,
  lightdm-enso-os-greeter,
  linkFarm,
  pcre,
  pkg-config,
  vala,
  wrapGAppsHook3,
}:

stdenv.mkDerivation {
  pname = "lightdm-enso-os-greeter";
  version = "0.2.1";

  src = fetchFromGitHub {
    owner = "nick92";
    repo = "Enso-OS";
    rev = "ed48330bfd986072bd82ac542ed8f8a7365c6427";
    sha256 = "sha256-v79J5KyjeJ99ifN7nK/B+J7f292qDAEHsmsHLAMKVYY=";
  };

  patches = [
    ./fix-paths.patch
  ];

  nativeBuildInputs = [
    cmake
    pkg-config
    vala
    wrapGAppsHook3
  ];

  buildInputs = [
    dbus
    gtk3
    pcre
    libepoxy
    libgee
    libx11
    lightdm
    libxdmcp
    gdk-pixbuf
    clutter-gtk
    libxklavier
    at-spi2-core
    libxkbcommon
    libpthread-stubs
    librsvg
  ];

  preConfigure = ''
    cd greeter
  '';

  postFixup = ''
    substituteInPlace $out/share/xgreeters/pantheon-greeter.desktop \
      --replace "pantheon-greeter" "$out/bin/pantheon-greeter"
  '';

  passthru.xgreeters = linkFarm "enso-os-greeter-xgreeters" [
    {
      name = "pantheon-greeter.desktop";
      path = "${lightdm-enso-os-greeter}/share/xgreeters/pantheon-greeter.desktop";
    }
  ];

  meta = {
    description = ''
      A fork of pantheon greeter that positions elements in a central and
      vertigal manner and adds a blur effect to the background
    '';

    homepage = "https://github.com/nick92/Enso-OS";
    license = lib.licenses.gpl3;

    maintainers = with lib.maintainers; [
      eadwu
    ];

    platforms = lib.platforms.linux;
    mainProgram = "pantheon-greeter";
  };
}
