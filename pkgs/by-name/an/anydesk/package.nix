{
  lib,
  stdenv,
  fetchurl,
  atk,
  cairo,
  copyDesktopItems,
  dbus,
  fontconfig,
  freetype,
  gdk-pixbuf,
  glib,
  gtk3,
  harfbuzz,
  jq,
  libGL,
  libGLU,
  libepoxy,
  libice,
  libsm,
  libx11,
  libxcb,
  libxdamage,
  libxext,
  libxfixes,
  libxi,
  libxkbcommon,
  libxkbfile,
  libxmu,
  libxrandr,
  libxrender,
  libxt,
  libxtst,
  libz,
  lsb-release,
  makeDesktopItem,
  makeWrapper,
  minizip,
  net-tools,
  pango,
  pciutils,
  polkit,
  polkit_gnome,
  pulseaudio,
  udev,
  wayland,
  writeShellScript,
}:

let
  description = "Desktop sharing application, providing remote support and online meetings";
  pin = lib.importJSON ./pin.json;
  inherit (pin) version;
  inherit (stdenv.hostPlatform) system;
  url =
    if system == "x86_64-linux" then
      "https://download.anydesk.com/linux/anydesk-${version}-amd64.tar.gz"
    else if system == "aarch64-linux" then
      "https://download.anydesk.com/rpi/anydesk-${version}-arm64.tar.gz"
    else
      throw "cannot install AnyDesk on ${system}";
  hash = pin.${system};
in
stdenv.mkDerivation (finalAttrs: {
  inherit version;
  pname = "anydesk";

  src = fetchurl {
    inherit url hash;
  };

  postPatch = ''
    substituteInPlace systemd/anydesk.service --replace-fail "/usr/bin/anydesk" "$out/bin/anydesk"
  '';

  nativeBuildInputs = [
    copyDesktopItems
    makeWrapper
  ];

  buildInputs = [
    atk
    cairo
    gdk-pixbuf
    glib
    gtk3
    dbus
    harfbuzz
    libz
    stdenv.cc.cc
    pango
    libGLU
    libGL
    minizip
    freetype
    fontconfig
    polkit
    polkit_gnome
    pulseaudio
    libxcb
    libxkbfile
    libx11
    libxdamage
    libxext
    libxfixes
    libxi
    libxmu
    libxrandr
    libxtst
    libxt
    libice
    libsm
    libxrender
    udev
    libxkbcommon
    wayland
    libepoxy
  ];

  installPhase = ''
    runHook preInstall

    mkdir -p $out/bin $out/share/{applications,doc/anydesk,icons/hicolor} $out/lib/systemd/system
    install -m755 anydesk $out/bin/anydesk
    cp copyright README $out/share/doc/anydesk
    cp -r icons/hicolor/* $out/share/icons/hicolor/
    cp systemd/anydesk.service $out/lib/systemd/system/anydesk.service

    runHook postInstall
  '';

  postFixup = ''
    patchelf \
      --set-interpreter $(cat $NIX_CC/nix-support/dynamic-linker) \
      --set-rpath "${lib.makeLibraryPath finalAttrs.buildInputs}" \
      $out/bin/anydesk

    wrapProgram $out/bin/anydesk \
      --prefix PATH : ${
        lib.makeBinPath [
          lsb-release
          pciutils
        ]
      } \
      --prefix GDK_BACKEND : x11 \
      --suffix PATH : ${
        lib.makeBinPath [
          net-tools
        ]
      } \
      --set GTK_THEME Adwaita
  '';

  desktopItems = [
    (makeDesktopItem {
      categories = [ "Network" ];
      desktopName = "AnyDesk";
      exec = "anydesk %u";
      genericName = description;
      icon = "anydesk";
      name = "AnyDesk";
      startupNotify = false;
    })
  ];

  passthru = {
    updateScript = ./update.sh;
  };

  meta = {
    inherit description;
    homepage = "https://www.anydesk.com";
    license = lib.licenses.unfree;
    sourceProvenance = with lib.sourceTypes; [ binaryNativeCode ];
    maintainers = with lib.maintainers; [ fraioveio ];

    platforms = [
      "x86_64-linux"
      "aarch64-linux"
    ];

    mainProgram = "anydesk";
  };
})
