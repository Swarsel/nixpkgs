{
  lib,
  stdenv,
  fetchFromGitHub,
  autoreconfHook,
  cairomm,
  pkg-config,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "adaptagrams";
  version = "0-unstable-2025-10-28";

  src = fetchFromGitHub {
    owner = "mjwybrow";
    repo = "adaptagrams";
    rev = "840ebcff20dbba36ad03a2160edf7cbaf9859984";
    hash = "sha256-7tzDOass0ea+6vnfyA/jl2k6VWHCMtkE2I/eTeCFiYQ=";
  };

  strictDeps = true;

  nativeBuildInputs = [
    autoreconfHook
    pkg-config
  ];

  buildInputs = [
    cairomm
  ];

  __structuredAttrs = true;
  sourceRoot = "source/cola";

  meta = {
    description = "Libraries for constraint-based layout and connector routing for diagrams.";
    homepage = "https://github.com/mjwybrow/adaptagrams";
    license = lib.licenses.lgpl21Plus;

    maintainers = with lib.maintainers; [
      wishstudio
    ];

    platforms = lib.platforms.all;
  };
})
