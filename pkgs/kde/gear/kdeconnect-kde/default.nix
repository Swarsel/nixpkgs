{
  lib,
  libei,
  libevdev,
  libfakekey,
  mkKdeDerivation,
  pkg-config,
  qtbase,
  qtconnectivity,
  qtmultimedia,
  replaceVars,
  sshfs,
  wayland,
  wayland-protocols,
}:
mkKdeDerivation {
  pname = "kdeconnect-kde";

  patches = [
    (replaceVars ./hardcode-sshfs-path.patch {
      sshfs = lib.getExe sshfs;
    })
  ];

  # Hardcoded as a QString, which is UTF-16 so Nix can't pick it up automatically
  postFixup = ''
    mkdir -p $out/nix-support
    echo "${sshfs}" > $out/nix-support/depends
  '';

  extraBuildInputs = [
    qtconnectivity
    qtmultimedia
    wayland
    wayland-protocols
    libei
    libevdev
    libfakekey
  ];

  extraCmakeFlags = [
    "-DQtWaylandScanner_EXECUTABLE=${qtbase}/libexec/qtwaylandscanner"
  ];

  extraNativeBuildInputs = [ pkg-config ];
}
