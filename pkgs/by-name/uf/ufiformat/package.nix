{
  lib,
  stdenv,
  fetchFromGitHub,
  e2fsprogs,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "ufiformat";
  version = "0.9.9";

  src = fetchFromGitHub {
    owner = "tedigh";
    repo = "ufiformat";
    rev = "v${finalAttrs.version}";
    sha256 = "heFETZj9migz2s9kvmw0ZQ1ieNpU4V4Lwfp91ek2cS4=";
  };

  buildInputs = [
    e2fsprogs
  ];

  meta = {
    description = "Low-level disk formatting utility for USB floppy drives";
    homepage = "https://github.com/tedigh/ufiformat";
    license = lib.licenses.gpl2Plus;
    maintainers = [ lib.maintainers.amarshall ];
    platforms = lib.platforms.linux;
    mainProgram = "ufiformat";
  };
})
