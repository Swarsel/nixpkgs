{
  mkKdeDerivation,
  pkg-config,
  plasma-workspace,
  qtsensors,
  qtwayland,
}:
mkKdeDerivation {
  pname = "plasma-mobile";
  # FIXME: work around Qt 6.10 cmake API changes
  cmakeFlags = [ "-DQT_FIND_PRIVATE_MODULES=1" ];

  postFixup = ''
    substituteInPlace "$out/share/wayland-sessions/plasma-mobile.desktop" \
      --replace-fail \
        "$out/libexec/plasma-dbus-run-session-if-needed" \
        "${plasma-workspace}/libexec/plasma-dbus-run-session-if-needed"
  '';

  extraBuildInputs = [
    qtsensors
    qtwayland
  ];

  extraNativeBuildInputs = [ pkg-config ];
  passthru.providedSessions = [ "plasma-mobile" ];
}
