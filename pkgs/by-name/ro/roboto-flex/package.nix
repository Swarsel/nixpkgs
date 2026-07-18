{
  lib,
  fetchzip,
  installFonts,
  stdenvNoCC,
}:

stdenvNoCC.mkDerivation (finalAttrs: {
  pname = "roboto-flex";
  version = "3.200";

  src = fetchzip {
    url = "https://github.com/googlefonts/roboto-flex/releases/download/${finalAttrs.version}/roboto-flex-fonts.zip";
    hash = "sha256-p8BvE4f6zQLygl49hzYTXXVQFZEJjrlfUvjNW+miar4=";
  };

  nativeBuildInputs = [ installFonts ];
  sourceRoot = "${finalAttrs.src.name}/roboto-flex-fonts/fonts";

  meta = {
    description = "Google Roboto Flex family of fonts";
    homepage = "https://github.com/googlefonts/roboto-flex";
    license = lib.licenses.ofl;
    maintainers = [ lib.maintainers.romildo ];
    platforms = lib.platforms.all;
  };
})
