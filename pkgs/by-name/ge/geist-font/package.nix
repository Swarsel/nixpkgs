{
  lib,
  fetchzip,
  installFonts,
  stdenvNoCC,
}:

stdenvNoCC.mkDerivation (finalAttrs: {
  pname = "geist-font";
  version = "1.5.0";

  outputs = [
    "out"
    "webfont"
  ];

  nativeBuildInputs = [ installFonts ];
  sourceRoot = ".";

  srcs = [
    (fetchzip {
      hash = "sha256-p3nFuaQPvw4PLcb5AOhu9jiNCTzZD7st1MuJKTAzwKE=";
      url = "https://github.com/vercel/geist-font/releases/download/${finalAttrs.version}/geist-font-${finalAttrs.version}.zip";
    })
  ];

  meta = {
    description = "Font family created by Vercel in collaboration with Basement Studio";
    homepage = "https://vercel.com/font";
    license = lib.licenses.ofl;
    sourceProvenance = with lib.sourceTypes; [ binaryBytecode ];
    maintainers = with lib.maintainers; [ x0ba ];
    platforms = lib.platforms.all;
  };
})
