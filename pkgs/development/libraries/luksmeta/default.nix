{
  lib,
  stdenv,
  fetchFromGitHub,
  asciidoc,
  autoreconfHook,
  cryptsetup,
  pkg-config,
}:

stdenv.mkDerivation rec {
  pname = "luksmeta";
  version = "10";

  src = fetchFromGitHub {
    owner = "latchset";
    repo = "luksmeta";
    tag = "v${version}";
    hash = "sha256-oasodAfUOgq2s0l+MIfCBTMo0ouXy73prVDnjLfMJA8=";
  };

  nativeBuildInputs = [
    autoreconfHook
    pkg-config
    asciidoc
  ];

  buildInputs = [ cryptsetup ];

  meta = {
    description = "Simple library for storing metadata in the LUKSv1 header";
    homepage = "https://github.com/latchset/luksmeta/";
    license = lib.licenses.lgpl21Plus;
    maintainers = with lib.maintainers; [ fpletz ];
    mainProgram = "luksmeta";
  };
}
