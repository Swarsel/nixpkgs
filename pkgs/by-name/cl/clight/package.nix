{
  lib,
  stdenv,
  fetchFromGitHub,
  bash-completion,
  clightd,
  cmake,
  dbus,
  geoclue2,
  gsl,
  libconfig,
  libmodule,
  pkg-config,
  popt,
  systemd,
  upower,
  withGeoclue ? true,
  withUpower ? true,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "clight";
  version = "4.11";

  src = fetchFromGitHub {
    owner = "FedeDP";
    repo = "Clight";
    tag = finalAttrs.version;
    hash = "sha256-Fu38HRP83Yn2jsq9xnCWOXNlV/0hJKD1/cOOp3EV45Q=";
  };

  nativeBuildInputs = [
    dbus
    cmake
    pkg-config
    bash-completion
  ];

  buildInputs = [
    gsl
    popt
    upower
    clightd
    systemd
    geoclue2
    libconfig
    libmodule
  ]
  ++ lib.optional withGeoclue geoclue2
  ++ lib.optional withUpower upower;

  cmakeFlags = [
    "-DSESSION_BUS_DIR=${placeholder "out"}/share/dbus-1/services"
    "-DBASH_COMPLETIONS_DIR=${placeholder "out"}/share/bash-completions/completions"
    "-DZSH_COMPLETIONS_DIR=${placeholder "out"}/share/zsh/site-functions"
  ];

  meta = {
    description = "C daemon that turns your webcam into a light sensor";
    homepage = "https://github.com/FedeDP/Clight";
    license = lib.licenses.gpl3;

    maintainers = with lib.maintainers; [
      eadwu
    ];

    platforms = lib.platforms.linux;
    mainProgram = "clight";
  };
})
