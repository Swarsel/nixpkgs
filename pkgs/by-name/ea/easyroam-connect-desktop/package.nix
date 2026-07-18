{
  lib,
  stdenv,
  fetchurl,
  autoPatchelfHook,
  cairo,
  dpkg,
  glib,
  glib-networking,
  gtk3,
  harfbuzz,
  libsecret,
  libsoup_3,
  networkmanager,
  pango,
  webkitgtk_4_1,
  wrapGAppsHook3,
}:
stdenv.mkDerivation rec {
  pname = "easyroam-connect-desktop";
  version = "1.4.3";

  src = fetchurl {
    url = "https://packages.easyroam.de/repos/easyroam-desktop/pool/main/e/easyroam-desktop/easyroam_connect_desktop-${version}+${version}-linux.deb";
    hash = "sha256-03PLAUQQWlaAO+0cYcCorc1Q6wAhvLQGXNu0mqh8Lvw=";
  };

  nativeBuildInputs = [
    autoPatchelfHook
    wrapGAppsHook3
    dpkg
  ];

  buildInputs = [
    glib
    gtk3
    pango
    cairo
    harfbuzz
    libsecret
    networkmanager
    webkitgtk_4_1
    libsoup_3
    glib-networking
  ];

  installPhase = ''
    runHook preInstall

    mkdir -p $out/bin
    cp -r usr/share $out/share
    ln -s $out/share/easyroam_connect_desktop/easyroam_connect_desktop $out/bin/easyroam_connect_desktop

    runHook postInstall
  '';

  dontBuild = true;
  dontConfigure = true;

  meta = {
    description = "Manage and install your easyroam WiFi profiles";

    longDescription = ''
      Using this software you can easily connect your device to eduroam® by simply logging in with your DFN-AAI account.
    '';

    homepage = "https://easyroam.de";
    license = lib.licenses.unfree;

    maintainers = with lib.maintainers; [
      shadows_withal
      MarchCraft
    ];

    platforms = [ "x86_64-linux" ];
    mainProgram = "easyroam_connect_desktop";
  };
}
