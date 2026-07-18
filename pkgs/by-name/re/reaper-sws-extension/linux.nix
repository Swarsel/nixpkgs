{
  lib,
  stdenv,
  fetchFromGitHub,
  cmake,
  git,
  gtk3,
  meta,
  perl,
  php,
  pkg-config,
  pname,
  version,
}:
stdenv.mkDerivation (finalAttrs: {
  inherit pname version meta;

  src = fetchFromGitHub {
    owner = "reaper-oss";
    repo = "sws";
    tag = "v${finalAttrs.version}";
    hash = "sha256-J2igVacDClHgKGZ2WATcd5XW2FkarKtALxVLgqa90Cs=";
    fetchSubmodules = true;
  };

  strictDeps = true;

  nativeBuildInputs = [
    cmake
    git
    perl
    php
    pkg-config
  ];

  buildInputs = [ gtk3 ];

})
