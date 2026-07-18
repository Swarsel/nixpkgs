{
  lib,
  stdenv,
  fetchurl,
  libogg,
  libvorbis,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "vorbisgain";
  version = "0.37";

  src = fetchurl {
    url = "https://sjeng.org/ftp/vorbis/vorbisgain-${finalAttrs.version}.tar.gz";
    sha256 = "1v1h6mhnckmvvn7345hzi9abn5z282g4lyyl4nnbqwnrr98v0vfx";
  };

  patches = [
    ./isatty.patch
    ./fprintf.patch
  ];

  buildInputs = [
    libogg
    libvorbis
  ];

  meta = {
    description = "Utility that corrects the volume of an Ogg Vorbis file to a predefined standardized loudness";
    homepage = "https://sjeng.org/vorbisgain.html";
    license = lib.licenses.gpl2Only;
    maintainers = with lib.maintainers; [ pSub ];
    platforms = lib.platforms.unix;
    mainProgram = "vorbisgain";
  };
})
