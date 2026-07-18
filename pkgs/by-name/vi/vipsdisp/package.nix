{
  lib,
  stdenv,
  fetchFromGitHub,
  fetchpatch2,
  gtk4,
  meson,
  ninja,
  pkg-config,
  python3,
  vips,
  wrapGAppsHook4,
}:

stdenv.mkDerivation rec {
  pname = "vipsdisp";
  version = "4.1.4";

  src = fetchFromGitHub {
    owner = "jcupitt";
    repo = "vipsdisp";
    tag = "v${version}";
    hash = "sha256-DXXDU/EtpWfNvV0PhQ+qjlxTBNERn9GGNeD00n9ejN0=";
  };

  postPatch = ''
    chmod +x ./meson_post_install.py
    patchShebangs ./meson_post_install.py
  '';

  nativeBuildInputs = [
    meson
    ninja
    pkg-config
    wrapGAppsHook4
  ];

  buildInputs = [
    vips
    gtk4
    python3
  ];

  # No tests implemented.
  doCheck = false;

  meta = {
    description = "Tiny image viewer with libvips";
    homepage = "https://github.com/jcupitt/vipsdisp";
    license = lib.licenses.mit;
    maintainers = [ ];
    platforms = lib.platforms.unix;
    mainProgram = "vipsdisp";
  };
}
