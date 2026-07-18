{
  lib,
  fetchurl,
  stdenvNoCC,
}:

stdenvNoCC.mkDerivation rec {
  pname = "lxgw-neoxihei";
  version = "1.304";

  src = fetchurl {
    url = "https://github.com/lxgw/LxgwNeoXiHei/releases/download/v${version}/LXGWNeoXiHei.ttf";
    hash = "sha256-WWXdmSKQhhxtYihQmNxcp/bGaZMHZf0R1dD9SRLYFuc=";
  };

  installPhase = ''
    runHook preInstall

    install -Dm644 $src $out/share/fonts/truetype/LXGWNeoXiHei.ttf

    runHook postInstall
  '';

  dontUnpack = true;

  meta = {
    description = "Simplified Chinese sans-serif font derived from IPAex Gothic";
    homepage = "https://github.com/lxgw/LxgwNeoXiHei";
    license = lib.licenses.ipa;
    maintainers = with lib.maintainers; [ zendo ];
    platforms = lib.platforms.all;
  };
}
