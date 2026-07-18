{
  lib,
  stdenv,
  fetchFromGitLab,
}:

let
  common = import ./common.nix { inherit lib fetchFromGitLab; };
  headers = [
    "include/GL/internal/dri_interface.h"
    "include/EGL/eglext_angle.h"
    "include/EGL/eglmesaext.h"
  ];
in
stdenv.mkDerivation rec {
  inherit (common) meta;
  pname = "mesa-gl-headers";
  # These are a bigger rebuild and don't change often, so keep them separate.
  version = "25.1.0";

  src = fetchFromGitLab {
    owner = "mesa";
    repo = "mesa";
    rev = "mesa-${version}";
    hash = "sha256-UlI+6OMUj5F6uVAw+Mg2wOZrjfdRq73d1qufaXVI/go";
    domain = "gitlab.freedesktop.org";
  };

  installPhase = ''
    for header in ${toString headers}; do
      install -Dm444 $header $out/$header
    done
  '';

  dontBuild = true;
  passthru = { inherit headers; };
}
