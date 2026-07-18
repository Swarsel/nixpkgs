{
  lib,
  fetchzip,
  installFonts,
  stdenvNoCC,
}:

stdenvNoCC.mkDerivation (finalAttrs: {
  pname = "roboto";
  version = "3.015";

  src = fetchzip {
    url = "https://github.com/googlefonts/roboto-3-classic/releases/download/v${finalAttrs.version}/Roboto_v${finalAttrs.version}.zip";
    hash = "sha256-vfn4KmOHHSVYT9XK+mDz5f4s8LnkCAY/IyTa3Rmir2k=";
    stripRoot = false;
  };

  nativeBuildInputs = [ installFonts ];
  sourceRoot = "${finalAttrs.src.name}/unhinted/static";

  meta = {
    description = "This is a variable version of Roboto intended to be a 1:1 match with the official non-variable release from Google";

    longDescription = ''
      This is not an official Google project, but was enabled with generous
      funding by Google Fonts, who contracted Type Network. The Roboto family of
      instances contained 6 weights and two widths of normal, along with italic
      of the regular width.
    '';

    homepage = "https://github.com/googlefonts/roboto-3-classic";
    license = lib.licenses.ofl;
    maintainers = [ lib.maintainers.romildo ];
    platforms = lib.platforms.all;
  };
})
