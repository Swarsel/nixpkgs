{
  dbus,
  kitemmodels,
  mkKdeDerivation,
  pkg-config,
  plasma5support,
  qtsensors,
  qtwayland,
  wayland-protocols,
}:
mkKdeDerivation {
  pname = "kscreen";

  postFixup = ''
    substituteInPlace $out/share/kglobalaccel/org.kde.kscreen.desktop \
      --replace-fail dbus-send ${dbus}/bin/dbus-send
  '';

  extraBuildInputs = [
    qtsensors
    qtwayland

    kitemmodels
    plasma5support

    wayland-protocols
  ];

  extraNativeBuildInputs = [ pkg-config ];
  meta.mainProgram = "kscreen-console";
}
