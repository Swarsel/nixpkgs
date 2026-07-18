{
  lib,
  stdenv,
  fetchFromGitHub,
  autoreconfHook,
  fdk_aac,
  pkg-config,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "fdkaac";
  version = "1.0.7";

  src = fetchFromGitHub {
    owner = "nu774";
    repo = "fdkaac";
    rev = "v${finalAttrs.version}";
    hash = "sha256-Yx+adbWs1qmuK+geHjCj7i56URDLVrUdLbJ2gKrJ1Oo=";
  };

  nativeBuildInputs = [
    autoreconfHook
    pkg-config
  ];

  buildInputs = [ fdk_aac ];
  doCheck = true;

  meta = {
    description = "Command line encoder frontend for libfdk-aac encoder";

    longDescription = ''
      fdkaac reads linear PCM audio in either WAV, raw PCM, or CAF format,
      and encodes it into either M4A / AAC file.
    '';

    homepage = "https://github.com/nu774/fdkaac";
    license = lib.licenses.zlib;
    maintainers = [ lib.maintainers.lunik1 ];
    platforms = lib.platforms.all;
    mainProgram = "fdkaac";
  };
})
