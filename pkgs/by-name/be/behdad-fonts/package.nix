{
  lib,
  fetchFromGitHub,
  installFonts,
  stdenvNoCC,
}:

stdenvNoCC.mkDerivation (finalAttrs: {
  pname = "behdad-fonts";
  version = "0.0.3";

  src = fetchFromGitHub {
    owner = "font-store";
    repo = "BehdadFont";
    tag = "v${finalAttrs.version}";
    hash = "sha256-gKfzxo3/bCMKXl2d6SP07ahIiNrUyrk/SN5XLND2lWY=";
  };

  outputs = [
    "out"
    "webfont"
  ];

  nativeBuildInputs = [ installFonts ];

  meta = {
    description = "Persian/Arabic Open Source Font";
    homepage = "https://github.com/font-store/BehdadFont";
    license = lib.licenses.ofl;
    maintainers = with lib.maintainers; [ pancaek ];
    platforms = lib.platforms.all;
  };
})
