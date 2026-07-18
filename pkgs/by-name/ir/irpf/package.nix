{
  lib,
  copyDesktopItems,
  fetchzip,
  imagemagick,
  jdk17,
  makeDesktopItem,
  makeWrapper,
  stdenvNoCC,
  unzip,
  writeScript,
  xdg-utils,
}:
let
  # The officially recommended version is Java 17
  java = jdk17;
in
stdenvNoCC.mkDerivation (finalAttrs: {
  pname = "irpf";
  version = "2026-1.5";

  # https://www.gov.br/receitafederal/pt-br/centrais-de-conteudo/download/pgd/dirpf
  # Para outros sistemas operacionais -> Multi
  src =
    let
      year = lib.head (lib.splitVersion finalAttrs.version);
    in
    fetchzip {
      url = "https://downloadirpf.receita.fazenda.gov.br/irpf/${year}/irpf/arquivos/IRPF${finalAttrs.version}.zip";
      hash = "sha256-/y0XE+i+Sug/2TfqQuPQesYaDVn41v3hkikU/hmxxNE=";
    };

  nativeBuildInputs = [
    unzip
    makeWrapper
    copyDesktopItems
    imagemagick
  ];

  installPhase = ''
    runHook preInstall

    BASEDIR="$out/share/irpf"
    mkdir -p "$BASEDIR"

    cp --no-preserve=mode -r help lib lib-modulos "$BASEDIR"

    install -Dm644 irpf.jar Leia-me.htm offline.png online.png pgd-updater-*.*.*.jar "$BASEDIR"

    # make xdg-open overrideable at runtime
    makeWrapper ${lib.getExe java} $out/bin/irpf \
      --add-flags "-Dawt.useSystemAAFontSettings=gasp" \
      --add-flags "-Dswing.aatext=true" \
      --add-flags "-jar $BASEDIR/irpf.jar" \
      --suffix PATH : ${lib.makeBinPath [ xdg-utils ]} \
      --set _JAVA_AWT_WM_NONREPARENTING 1 \
      --set AWT_TOOLKIT MToolkit

    mkdir -p $out/share/icons/hicolor/{96x96,72x72,32x32}/apps
    unzip -jp lib/ppgd-icones-4.0.jar icones/rfb64.png | magick - -background none -gravity center -extent 96x96 $out/share/icons/hicolor/96x96/apps/rfb.png
    unzip -jp lib/ppgd-icones-4.0.jar icones/rfb48.png | magick - -background none -gravity center -extent 72x72 $out/share/icons/hicolor/72x72/apps/rfb.png
    unzip -j lib/ppgd-icones-4.0.jar icones/rfb.png -d $out/share/icons/hicolor/32x32/apps

    runHook postInstall
  '';

  desktopItems = [
    (makeDesktopItem {
      categories = [ "Office" ];
      comment = "Programa Oficial da Receita para elaboração do IRPF";
      desktopName = "Imposto de Renda Pessoa Física";
      exec = "irpf";
      icon = "rfb";
      name = "irpf";
    })
  ];

  passthru.updateScript = writeScript "update-irpf" ''
    #!/usr/bin/env nix-shell
    #!nix-shell -i bash -p curl pup common-updater-scripts

    set -eu -o pipefail
    #parses the html with the install links for the containers that contain the instalation files of type 'file archive, gets the version number of each version, and sorts to get the latest one on the website
    version="$(curl -s https://www.gov.br/receitafederal/pt-br/centrais-de-conteudo/download/pgd/dirpf | pup '.rfb_container .rfb_ositem:parent-of(.fa-file-archive) attr{href}' | grep -oP "IRPF\K(\d+)-[\d.]+\d" | sort -r |  head -1)"
    update-source-version irpf "$version"
  '';

  meta = {
    description = "Brazillian government application for reporting income tax";

    longDescription = ''
      Brazillian government application for reporting income tax.

      IRFP - Imposto de Renda Pessoa Física - Receita Federal do Brasil.
    '';

    homepage = "https://www.gov.br/receitafederal/pt-br";
    license = lib.licenses.unfree;
    sourceProvenance = with lib.sourceTypes; [ binaryBytecode ];

    maintainers = with lib.maintainers; [
      rafaelrc
    ];

    platforms = lib.platforms.all;
    mainProgram = "irpf";
  };
})
