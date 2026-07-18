{
  lib,
  stdenv,
  fetchurl,
  testers,
}:

let
  versions = lib.importJSON ./versions.json;
  arch =
    if stdenv.hostPlatform.isi686 then
      "386"
    else if stdenv.hostPlatform.isx86_64 then
      "amd64"
    else if stdenv.hostPlatform.isAarch32 then
      "arm"
    else if stdenv.hostPlatform.isAarch64 then
      "arm64"
    else
      throw "Unsupported architecture";
  os =
    if stdenv.hostPlatform.isLinux then
      "linux"
    else if stdenv.hostPlatform.isDarwin then
      "darwin"
    else
      throw "Unsupported os";
  versionInfo = versions."${os}-${arch}";
  inherit (versionInfo) version sha256 url;

in
stdenv.mkDerivation (finalAttrs: {
  inherit version;
  pname = "ngrok";
  # run ./update
  src = fetchurl { inherit sha256 url; };

  buildPhase = ''
    runHook preBuild
    chmod a+x ngrok
    runHook postBuild
  '';

  installPhase = ''
    runHook preInstall
    install -D ngrok $out/bin/ngrok
    runHook postInstall
  '';

  # Stripping causes SEGFAULT on darwin
  dontStrip = stdenv.hostPlatform.isDarwin;
  sourceRoot = ".";

  unpackPhase = ''
    runHook preUnpack
    cp $src ngrok
    runHook postUnpack
  '';

  passthru = {
    tests.version = testers.testVersion { package = finalAttrs.finalPackage; };
    updateScript = ./update.sh;
  };

  meta = {
    description = "Allows you to expose a web server running on your local machine to the internet";
    homepage = "https://ngrok.com/";
    changelog = "https://ngrok.com/docs/agent/changelog/";
    license = lib.licenses.unfree;
    sourceProvenance = with lib.sourceTypes; [ binaryNativeCode ];

    maintainers = with lib.maintainers; [
      bobvanderlinden
      brodes
    ];

    platforms = lib.platforms.unix;
    mainProgram = "ngrok";
    downloadPage = "https://ngrok.com/download";
  };
})
