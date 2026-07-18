{
  lib,
  stdenv,
  fetchFromGitHub,
  autoreconfHook,
  e2fsprogs,
  pkg-config,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "e2tools";
  version = "0.1.2";

  src = fetchFromGitHub {
    owner = "e2tools";
    repo = "e2tools";
    tag = "v${finalAttrs.version}";
    hash = "sha256-h5Asz3bG1zMOwJBLWZY0NBLRB3W8+6va6MkuOQvCuAc=";
  };

  nativeBuildInputs = [
    autoreconfHook
    pkg-config
  ];

  buildInputs = [ e2fsprogs ];
  enableParallelBuilding = true;

  meta = {
    description = "Utilities to read/write/manipulate files in an ext2/ext3 filesystem";
    homepage = "https://e2tools.github.io/";
    license = lib.licenses.gpl2Only;
    platforms = lib.platforms.linux;
  };
})
