{
  lib,
  stdenv,
  fetchFromGitHub,
  fasm,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "patcher9x";
  version = "0.8.50";
  buildInputs = [ fasm ];

  preBuild = ''
    rmdir nocrt
    ln -s ../nocrt .
  '';

  installPhase = ''
    runHook preInstall
    install -D patcher9x $out/bin/patcher9x
    runHook postInstall
  '';

  hardeningDisable = [ "fortify" ];
  sourceRoot = "src";

  srcs = [
    (fetchFromGitHub {
      hash = "sha256-TZw2+R7Dzojzxzal1Wp8jhe5gwU4CfZDROITi5Z+auo=";
      name = "src";
      owner = "JHRobotics";
      repo = "patcher9x";
      rev = "v${finalAttrs.version}";
    })

    (fetchFromGitHub {
      hash = "sha256-oeHcK9zYMDWk5sWfzYqLtC3MAJVtcaDJy4PvUGrxiPE=";
      name = "nocrt";
      owner = "JHRobotics";
      repo = "nocrt";
      rev = "f65cc7ef2a3cccd6264b2eb265d7fffbecb06ba4";
    })
  ];

  meta = {
    description = "Patch for Windows 95/98/98 SE/Me to fix CPU issues";
    homepage = "https://github.com/JHRobotics/patcher9x";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ hughobrien ];
    platforms = lib.platforms.linux;
    mainProgram = "patcher9x";
  };
})
