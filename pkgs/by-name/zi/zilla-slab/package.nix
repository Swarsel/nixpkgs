{
  lib,
  fetchzip,
  installFonts,
  stdenvNoCC,
}:

stdenvNoCC.mkDerivation rec {
  pname = "zilla-slab";
  version = "1.002";

  src = fetchzip {
    url = "https://github.com/mozilla/zilla-slab/releases/download/v${version}/Zilla-Slab-Fonts-v${version}.zip";
    hash = "sha256-yOHu+dSWlyI7w1N1teED9R1Fphso2bKAlYDC1KdqBCc=";
    stripRoot = false;
  };

  outputs = [
    "out"
    "webfont"
  ];

  nativeBuildInputs = [ installFonts ];

  meta = {
    description = "Zilla Slab fonts";

    longDescription = ''
      Zilla Slab is Mozilla's core typeface, used
      for the Mozilla wordmark, headlines and
      throughout their designs. A contemporary
      slab serif, based on Typotheque's Tesla, it
      is constructed with smooth curves and true
      italics, which gives text an unexpectedly
      sophisticated industrial look and a friendly
      approachability in all weights.
    '';

    homepage = "https://github.com/mozilla/zilla-slab";
    license = lib.licenses.ofl;
    maintainers = with lib.maintainers; [ caugner ];
    platforms = lib.platforms.all;
  };
}
