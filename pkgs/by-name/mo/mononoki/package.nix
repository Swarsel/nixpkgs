{
  lib,
  fetchzip,
  installFonts,
  stdenvNoCC,
}:

stdenvNoCC.mkDerivation (finalAttrs: {

  pname = "mononoki";
  version = "1.6";

  src = fetchzip {
    url = "https://github.com/madmalik/mononoki/releases/download/${finalAttrs.version}/mononoki.zip";
    hash = "sha256-HQM9rzIJXLOScPEXZu0MzRlblLfbVVNJ+YvpONxXuwQ=";
    stripRoot = false;
  };

  nativeBuildInputs = [ installFonts ];

  meta = {
    description = "Font for programming and code review";
    homepage = "https://github.com/madmalik/mononoki";
    license = lib.licenses.ofl;
    platforms = lib.platforms.all;
  };
})
