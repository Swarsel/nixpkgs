{
  lib,
  stdenv,
  fetchFromGitHub,
  pkg-config,
  readline,
  unstableGitUpdater,
  xercesc,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "ringing-lib";
  version = "0-unstable-2026-05-12";

  src = fetchFromGitHub {
    owner = "ringing-lib";
    repo = "ringing-lib";
    rev = "6d7533186fb89497ab059b91d0e7bd7911cd3f71";
    hash = "sha256-yxf9w8USn9SVL4QW6XUWwR1rObvbj6Z69O3he3JiGT4=";
  };

  strictDeps = true;

  nativeBuildInputs = [
    pkg-config
  ];

  buildInputs = [
    readline
    xercesc
  ];

  makeFlags = [ "PREFIX=${placeholder "out"}" ];
  doCheck = true;
  passthru.updateScript = unstableGitUpdater { hardcodeZeroVersion = true; };

  meta = {
    description = "Library of C++ classes and utilities for change ringing";
    homepage = "https://ringing-lib.github.io/";

    license = with lib.licenses; [
      gpl2Plus
      lgpl2Plus
    ];

    maintainers = with lib.maintainers; [ jshholland ];
    platforms = lib.platforms.linux;
  };
})
