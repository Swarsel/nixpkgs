{
  lib,
  stdenv,
  fetchFromGitHub,
  ddcutil,
  # buildInputs
  glib,
  # nativeBuildInputs
  pkg-config,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "ddcutil-service";
  version = "1.0.15";

  src = fetchFromGitHub {
    owner = "digitaltrails";
    repo = "ddcutil-service";
    rev = "v${finalAttrs.version}";
    hash = "sha256-r66Ua+4jGl1wFEX3RoRHN60GujNApGbDHtJnVDtP3Z4=";
  };

  nativeBuildInputs = [
    pkg-config
  ];

  buildInputs = [
    glib
    ddcutil
  ];

  makeFlags = [
    "PREFIX=${placeholder "out"}"
  ];

  # Also installs ddcutil-client, which is built by default
  installTargets = "install-all";

  meta = {
    description = "A Dbus ddcutil server for control of DDC Monitors/VDUs";
    homepage = "https://github.com/digitaltrails/ddcutil-service";
    license = lib.licenses.gpl2Only;
    maintainers = with lib.maintainers; [ doronbehar ];
    platforms = lib.platforms.linux;
    mainProgram = "ddcutil-service";
  };
})
