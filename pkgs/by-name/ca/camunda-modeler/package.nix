{
  lib,
  fetchurl,
  copyDesktopItems,
  electron,
  makeDesktopItem,
  makeWrapper,
  stdenvNoCC,
}:

stdenvNoCC.mkDerivation rec {
  pname = "camunda-modeler";
  version = "5.48.0";

  src = fetchurl {
    url = "https://github.com/camunda/camunda-modeler/releases/download/v${version}/camunda-modeler-${version}-linux-x64.tar.gz";
    hash = "sha256-92KWs2mLcKMhM/v3GRkX5CFcRrtPA1viczZVFkAdVLQ=";
  };

  nativeBuildInputs = [
    makeWrapper
    copyDesktopItems
  ];

  installPhase = ''
    runHook preInstall

    mkdir -p $out/bin $out/share/${pname}
    cp -a {locales,resources} $out/share/${pname}
    install -Dm644 support/mime-types.xml $out/share/mime/packages/${pname}.xml

    for SIZE in 16 48 128; do
      install -D -m0644 support/icon_''${SIZE}.png "$out/share/icons/hicolor/''${SIZE}x''${SIZE}/apps/${pname}.png"
    done

    runHook postInstall
  '';

  postFixup = ''
    makeWrapper ${electron}/bin/electron $out/bin/${pname} \
      --add-flags $out/share/${pname}/resources/app.asar
  '';

  desktopItems = [
    (makeDesktopItem {
      comment = meta.description;
      desktopName = "Camunda Modeler";
      exec = pname;

      extraConfig = {
        X-Ayatana-Desktop-Shortcuts = "NewWindow;RepositoryBrowser";
      };

      genericName = "Process Modeling Tool";
      icon = pname;

      keywords = [
        "bpmn"
        "cmmn"
        "dmn"
        "form"
        "modeler"
        "camunda"
      ];

      mimeTypes = [
        "application/bpmn"
        "application/cmmn"
        "application/dmn"
        "application/camunda-form"
      ];

      name = pname;
    })
  ];

  dontBuild = true;
  dontConfigure = true;
  sourceRoot = "camunda-modeler-${version}-linux-x64";

  meta = {
    inherit (electron.meta) platforms;
    description = "Integrated modeling solution for BPMN, DMN and Forms based on bpmn.io";
    homepage = "https://github.com/camunda/camunda-modeler";
    license = lib.licenses.mit;

    maintainers = with lib.maintainers; [
      vringar
      johannwagner
    ];

    mainProgram = "camunda-modeler";
  };
}
