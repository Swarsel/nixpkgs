{
  lib,
  stdenv,
  fetchurl,
  autoreconfHook,
  libmediainfo,
  libzen,
  pkg-config,
  zlib,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "mediainfo";
  version = "26.05";

  src = fetchurl {
    url = "https://mediaarea.net/download/source/mediainfo/${finalAttrs.version}/mediainfo_${finalAttrs.version}.tar.xz";
    hash = "sha256-+FIJP5BQAi1plgbuq7OLJNpVI9AhL6tk3E5NPka1beE=";
  };

  nativeBuildInputs = [
    autoreconfHook
    pkg-config
  ];

  buildInputs = [
    libzen
    libmediainfo
    zlib
  ];

  configureFlags = [ "--with-libmediainfo=${libmediainfo}" ];
  enableParallelBuilding = true;
  sourceRoot = "MediaInfo/Project/GNU/CLI";

  meta = {
    description = "Supplies technical and tag information about a video or audio file";

    longDescription = ''
      MediaInfo is a convenient unified display of the most relevant technical
      and tag data for video and audio files.
    '';

    homepage = "https://mediaarea.net/";
    license = lib.licenses.bsd2;
    maintainers = [ lib.maintainers.devhell ];
    platforms = lib.platforms.unix;
    mainProgram = "mediainfo";
  };
})
