{
  lib,
  fetchzip,
  gitUpdater,
  installFonts,
  stdenvNoCC,
}:

stdenvNoCC.mkDerivation (finalAttrs: {
  pname = "beedii";
  version = "1.0.0";

  src = fetchzip {
    url = "https://github.com/webkul/beedii/releases/download/v${finalAttrs.version}/beedii.zip";
    hash = "sha256-MefkmWl7LdhQiePpixKcatoIeOTlrRaO3QA9xWAxJ4Q=";
    stripRoot = false;
  };

  outputs = [
    "out"
    "webfont"
  ];

  nativeBuildInputs = [ installFonts ];
  sourceRoot = "${finalAttrs.src.name}/Fonts";

  passthru.updateScript = gitUpdater {
    # This version does not include font files in the released assets.
    # https://github.com/webkul/beedii/issues/1
    ignoredVersions = "^1\\.2\\.0$";
    rev-prefix = "v";
    url = "https://github.com/webkul/beedii";
  };

  meta = {
    description = "Free Hand Drawn Emoji Font";
    homepage = "https://github.com/webkul/beedii";
    license = lib.licenses.cc0;

    maintainers = with lib.maintainers; [
      kachick
    ];

    platforms = lib.platforms.all;
  };
})
