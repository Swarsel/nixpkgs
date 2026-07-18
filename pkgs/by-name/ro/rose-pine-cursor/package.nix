{
  lib,
  fetchurl,
  stdenvNoCC,
}:

stdenvNoCC.mkDerivation (finalAttrs: {
  pname = "rose-pine-cursor";
  version = "1.1.0";

  installPhase = ''
    runHook preInstall
    mkdir -p $out/share/icons
    cp -R BreezeX-RosePine-Linux $out/share/icons/
    cp -R BreezeX-RosePineDawn-Linux $out/share/icons/
    runHook postInstall
  '';

  sourceRoot = ".";

  srcs = [
    (fetchurl {
      hash = "sha256-szDVnOjg5GAgn2OKl853K3jZ5rVsz2PIpQ6dlBKJoa8=";
      url = "https://github.com/rose-pine/cursor/releases/download/v${finalAttrs.version}/BreezeX-RosePine-Linux.tar.xz";
    })
    (fetchurl {
      hash = "sha256-hanfwx9ooT1TbmcgCr63KVYwC1OIzTwjmxzi4Zjcrdg=";
      url = "https://github.com/rose-pine/cursor/releases/download/v${finalAttrs.version}/BreezeX-RosePineDawn-Linux.tar.xz";
    })
  ];

  meta = {
    description = "Soho vibes for Cursors";
    homepage = "https://rosepinetheme.com/";
    license = lib.licenses.gpl3;
    maintainers = with lib.maintainers; [ aikooo7 ];
    downloadPage = "https://github.com/rose-pine/cursor/releases";
  };
})
