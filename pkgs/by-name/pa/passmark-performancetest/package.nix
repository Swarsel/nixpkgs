{
  lib,
  stdenv,
  fetchurl,
  autoPatchelfHook,
  coreutils,
  curl,
  dmidecode,
  makeWrapper,
  ncurses5,
  unzip,
  util-linux,
}:
let
  sources = {
    "aarch64-linux" = {
      hash = "sha256-7fmd2fukJ56e0BJFJe3SitGlordyIFbNjIzQv+u6Zuw=";
      url = "https://web.archive.org/web/20231205092807/https://www.passmark.com/downloads/pt_linux_arm64.zip";
    };

    "x86_64-linux" = {
      hash = "sha256-q9H+/V4fkSwJJEp+Vs+MPvndi5DInx5MQCzAv965IJg=";
      url = "https://web.archive.org/web/20231205092714/https://www.passmark.com/downloads/pt_linux_x64.zip";
    };
  };
in
stdenv.mkDerivation {
  pname = "passmark-performancetest";
  version = "11.0.1002";

  src = fetchurl (
    sources.${stdenv.system} or (throw "Unsupported system for PassMark performance test")
  );

  nativeBuildInputs = [
    unzip
    autoPatchelfHook
    makeWrapper
  ];

  buildInputs = [
    (lib.getLib stdenv.cc.cc)
    curl
    ncurses5
  ];

  installPhase = ''
    runHook preInstall
    install -Dm555 pt_linux_* "$out/bin/performancetest"
    runHook postInstall
  '';

  # Prefix since program will call sudo
  postFixup = ''
    wrapProgram $out/bin/performancetest \
        --prefix PATH ":" ${
          lib.makeBinPath [
            dmidecode
            coreutils
            util-linux
          ]
        }
  '';

  dontBuild = true;
  dontConfigure = true;

  meta = {
    description = "Software tool that allows everybody to quickly assess the performance of their computer and compare it to a number of standard 'baseline' computer systems";
    homepage = "https://www.passmark.com";
    license = lib.licenses.unfree;
    sourceProvenance = with lib.sourceTypes; [ binaryNativeCode ];
    maintainers = with lib.maintainers; [ neverbehave ];
    platforms = builtins.attrNames sources;
    mainProgram = "performancetest";
  };
}
