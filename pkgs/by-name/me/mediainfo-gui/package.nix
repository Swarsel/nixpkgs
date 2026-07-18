{
  lib,
  stdenv,
  fetchurl,
  autoreconfHook,
  desktop-file-utils,
  imagemagick,
  libmediainfo,
  libsm,
  pkg-config,
  wrapGAppsHook3,
  wxwidgets_3_2,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "mediainfo-gui";
  version = "26.05";

  src = fetchurl {
    url = "https://mediaarea.net/download/source/mediainfo/${finalAttrs.version}/mediainfo_${finalAttrs.version}.tar.xz";
    hash = "sha256-+FIJP5BQAi1plgbuq7OLJNpVI9AhL6tk3E5NPka1beE=";
  };

  nativeBuildInputs = [
    autoreconfHook
    pkg-config
    wrapGAppsHook3
  ];

  buildInputs = [
    libmediainfo
    wxwidgets_3_2
    desktop-file-utils
    libsm
    imagemagick
  ];

  enableParallelBuilding = true;
  sourceRoot = "MediaInfo/Project/GNU/GUI";

  meta = {
    description = "Supplies technical and tag information about a video or audio file (GUI version)";

    longDescription = ''
      MediaInfo is a convenient unified display of the most relevant technical
      and tag data for video and audio files.
    '';

    homepage = "https://mediaarea.net";
    license = lib.licenses.bsd2;
    maintainers = with lib.maintainers; [ devhell ];
    platforms = lib.platforms.unix;
    mainProgram = "mediainfo-gui";
  };
})
