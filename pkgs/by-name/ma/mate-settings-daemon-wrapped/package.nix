{
  stdenv,
  glib,
  mate-control-center,
  mate-settings-daemon,
  wrapGAppsHook3,
}:

stdenv.mkDerivation {
  inherit (mate-settings-daemon) version outputs;
  pname = "${mate-settings-daemon.pname}-wrapped";

  nativeBuildInputs = [
    wrapGAppsHook3
  ];

  buildInputs = [
    glib
    mate-control-center
  ];

  installPhase = ''
    mkdir -p $out/etc/xdg/autostart
    cp ${mate-settings-daemon}/etc/xdg/autostart/mate-settings-daemon.desktop $out/etc/xdg/autostart

    mkdir -p $out/share/man
    cp -r ${mate-settings-daemon.man}/share/man/* $out/share/man/
  '';

  postFixup = ''
    mkdir -p $out/libexec
    makeWrapper ${mate-settings-daemon}/libexec/mate-settings-daemon $out/libexec/mate-settings-daemon \
      "''${gappsWrapperArgs[@]}"
    substituteInPlace $out/etc/xdg/autostart/mate-settings-daemon.desktop \
      --replace-fail "${mate-settings-daemon}/libexec/mate-settings-daemon" "$out/libexec/mate-settings-daemon"
  '';

  dontUnpack = true;
  dontWrapGApps = true;

  meta = mate-settings-daemon.meta // {
    priority = -10;
  };
}
