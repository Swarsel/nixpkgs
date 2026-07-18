{
  lib,
  fetchzip,
  installFonts,
  stdenvNoCC,
}:

stdenvNoCC.mkDerivation (finalAttrs: {
  pname = "shantell-sans";
  version = "1.011";

  src = fetchzip {
    url = "https://github.com/arrowtype/shantell-sans/releases/download/${finalAttrs.version}/Shantell_Sans_${finalAttrs.version}.zip";
    hash = "sha256-xgE4BSl2A7yeVP5hWWUViBDoU8pZ8KkJJrsSfGRIjOk=";
  };

  outputs = [
    "out"
    "webfont"
  ];

  strictDeps = true;
  nativeBuildInputs = [ installFonts ];
  __structuredAttrs = true;

  meta = {
    description = "A marker-style variable font by ArrowType and Shantell Martin";
    homepage = "https://github.com/arrowtype/shantell-sans";
    license = lib.licenses.ofl;

    maintainers = with lib.maintainers; [
      benhaskins
    ];

    platforms = lib.platforms.all;
  };
})
