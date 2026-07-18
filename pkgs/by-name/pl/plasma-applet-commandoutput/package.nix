{
  lib,
  stdenv,
  fetchFromGitHub,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "plasma-applet-commandoutput";
  version = "13";

  src = fetchFromGitHub {
    owner = "Zren";
    repo = "plasma-applet-commandoutput";
    tag = "v${finalAttrs.version}";
    hash = "sha256-Tjnm26EYKXtBM9JBHKI73AMvOW/rQ3qOw2JDYey7EfQ=";
  };

  installPhase = ''
    runHook preInstall

    mkdir -p $out/share/plasma/plasmoids
    cp -r package $out/share/plasma/plasmoids/com.github.zren.commandoutput

    runHook postInstall
  '';

  dontBuild = true;
  dontConfigure = true;

  meta = {
    description = "Run a command periodically and render its output";
    homepage = "https://github.com/Zren/plasma-applet-commandoutput";
    changelog = "https://github.com/Zren/plasma-applet-commandoutput/blob/${finalAttrs.src.rev}/Changelog.md";
    license = lib.licenses.gpl2Plus;

    maintainers = with lib.maintainers; [
      matthiasbeyer
      oliver-ni
    ];
  };
})
