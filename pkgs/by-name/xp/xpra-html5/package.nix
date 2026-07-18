{
  lib,
  fetchFromGitHub,
  gitUpdater,
  python3,
  stdenvNoCC,
  uglify-js,
}:
stdenvNoCC.mkDerivation (finalAttrs: {
  pname = "xpra-html5";
  version = "17.1";

  src = fetchFromGitHub {
    owner = "Xpra-org";
    repo = "xpra-html5";
    tag = "v${finalAttrs.version}";
    hash = "sha256-vmv3L5Fcq1GF/txqHV6pCT530SFKm0RpfGmI4BLGGp0=";
  };

  buildInputs = [
    python3
    uglify-js
  ];

  installPhase = ''
    runHook preInstall
    python $src/setup.py install $out /share/xpra/www /share/xpra/www
    runHook postInstall
  '';

  passthru.updateScript = gitUpdater { rev-prefix = "v"; };

  meta = {
    description = "HTML5 client for Xpra";
    homepage = "https://xpra.org/";
    changelog = "https://github.com/Xpra-org/xpra-html5/releases/tag/v${finalAttrs.version}";
    license = lib.licenses.mpl20;
    maintainers = [ ];
    platforms = lib.platforms.linux;
    downloadPage = "https://xpra.org/src/";
  };
})
