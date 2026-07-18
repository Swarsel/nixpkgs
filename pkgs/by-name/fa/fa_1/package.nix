{
  lib,
  fetchzip,
  installFonts,
  stdenvNoCC,
}:

stdenvNoCC.mkDerivation (finalAttrs: {
  pname = "fa_1";
  version = "0.100";

  src = fetchzip {
    url = "https://dotcolon.net/files/fonts/fa_1_${lib.replaceString "." "" finalAttrs.version}.zip";
    hash = "sha256-BPJ+wZMYXY/yg5oEgBc5YnswA6A7w6V0gdv+cac0qdc=";
    stripRoot = false;
  };

  nativeBuildInputs = [ installFonts ];

  meta = {
    description = "Weighted decorative font";
    homepage = "https://dotcolon.net/font/fa_1/";
    license = lib.licenses.ofl;
    maintainers = with lib.maintainers; [ minijackson ];
    platforms = lib.platforms.all;
  };
})
