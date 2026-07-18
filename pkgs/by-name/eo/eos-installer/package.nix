{
  lib,
  stdenv,
  fetchFromGitHub,
  coreutils,
  glib,
  gnome-desktop,
  gnupg,
  gtk3,
  meson,
  ninja,
  pkg-config,
  python3,
  systemdMinimal,
  udisks,
  writeText,
  xz,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "eos-installer";
  version = "5.1.0";

  src = fetchFromGitHub {
    owner = "endlessm";
    repo = "eos-installer";
    tag = "Release_${finalAttrs.version}";
    sha256 = "BqvZglzFJabGXkI8hnLiw1r+CvM7kSKQPj8IKYBB6S4=";
    fetchSubmodules = true;
  };

  strictDeps = true;

  nativeBuildInputs = [
    glib
    gnupg
    meson
    ninja
    pkg-config
    python3
  ];

  buildInputs = [
    gnome-desktop
    gtk3
    systemdMinimal
    udisks
    xz
  ];

  mesonFlags = [
    "--libexecdir=${placeholder "out"}/bin"
    "--cross-file=${writeText "crossfile.ini" ''
      [binaries]
      gpg = '${gnupg}/bin/gpg'
    ''}"
  ];

  env.PKG_CONFIG_SYSTEMD_SYSTEMDSYSTEMUNITDIR = "${placeholder "out"}/lib/systemd/system";

  preConfigure = ''
    patchShebangs tests
    substituteInPlace tests/test-scribe.c \
        --replace /bin/true ${coreutils}/bin/true \
        --replace /bin/false ${coreutils}/bin/false
  '';

  doCheck = true;
  enableParallelBuilding = true;

  meta = {
    description = "Installer UI which writes images to disk";
    homepage = "https://github.com/endlessm/eos-installer";
    license = lib.licenses.gpl2Plus;
    maintainers = with lib.maintainers; [ qyliss ];
    platforms = lib.platforms.linux;
    mainProgram = "gnome-image-installer";
  };
})
