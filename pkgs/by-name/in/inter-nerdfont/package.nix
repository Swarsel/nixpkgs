{
  lib,
  fetchzip,
  fontforge,
  nerd-font-patcher,
  stdenvNoCC,
}:

stdenvNoCC.mkDerivation (finalAttrs: {
  pname = "inter-nerdfont";
  version = "4.1";

  src = fetchzip {
    url = "https://github.com/rsms/inter/releases/download/v${finalAttrs.version}/Inter-${finalAttrs.version}.zip";
    hash = "sha256-5vdKKvHAeZi6igrfpbOdhZlDX2/5+UvzlnCQV6DdqoQ=";
    stripRoot = false;
  };

  nativeBuildInputs = [
    fontforge
    nerd-font-patcher
  ];

  buildPhase = ''
    runHook preBuild
    nerd-font-patcher Inter.ttc
    runHook postBuild
  '';

  installPhase = ''
    runHook preInstall
    install -Dm444 'Inter Nerd Font.ttc' $out/share/fonts/truetype/InterNerdFont.ttc
    cp *.ttf $out/share/fonts/truetype
    runHook postInstall
  '';

  meta = {
    description = "NerdFont patch of the Inter font";
    homepage = "https://gitlab.com/mid_os/inter-nerdfont";
    license = lib.licenses.ofl;
    maintainers = [ lib.maintainers.midischwarz12 ];
    platforms = lib.platforms.all;
  };
})
