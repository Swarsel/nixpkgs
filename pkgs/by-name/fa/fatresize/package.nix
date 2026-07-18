{
  lib,
  stdenv,
  fetchFromGitHub,
  parted,
  pkg-config,
  util-linux,
}:

stdenv.mkDerivation (finalAttrs: {

  pname = "fatresize";
  version = "1.1.0";

  src = fetchFromGitHub {
    owner = "ya-mouse";
    repo = "fatresize";
    rev = "v${finalAttrs.version}";
    sha256 = "1vhz84kxfyl0q7mkqn68nvzzly0a4xgzv76m6db0bk7xyczv1qr2";
  };

  nativeBuildInputs = [ pkg-config ];

  buildInputs = [
    parted
    util-linux
  ];

  propagatedBuildInputs = [
    parted
    util-linux
  ];

  meta = {
    description = "FAT16/FAT32 non-destructive resizer";
    homepage = "https://github.com/ya-mouse/fatresize";
    license = lib.licenses.gpl3;
    platforms = lib.platforms.linux;
    mainProgram = "fatresize";
  };
})
