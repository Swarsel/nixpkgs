{
  lib,
  stdenv,
  fetchurl,
  _7zz,
  appimageTools,
}:

let
  pname = "dbgate";
  version = "7.2.1";
  src =
    fetchurl
      {
        aarch64-darwin = {
          hash = "sha256-luk0vWRc4x3QMYAPquTWiSW9FqTe1IsBm9qOoOeHOps=";
          url = "https://github.com/dbgate/dbgate/releases/download/v${version}/dbgate-${version}-mac_universal.dmg";
        };

        aarch64-linux = {
          hash = "sha256-OkAyKMXOYxvZomVUB5xIpPKR+b4p3+US7TDMIYeCsoo=";
          url = "https://github.com/dbgate/dbgate/releases/download/v${version}/dbgate-${version}-linux_arm64.AppImage";
        };

        x86_64-linux = {
          hash = "sha256-QR44QZ5QNz/q9Cfp/d5EYjlG84ZmCtBFe8a4aMFEhjQ=";
          url = "https://github.com/dbgate/dbgate/releases/download/v${version}/dbgate-${version}-linux_x86_64.AppImage";
        };
      }
      .${stdenv.hostPlatform.system} or (throw "dbgate: ${stdenv.hostPlatform.system} is unsupported.");

  passthru.updateScript = ./update.sh;

  meta = {
    description = "Database manager for MySQL, PostgreSQL, SQL Server, MongoDB, SQLite and others";
    homepage = "https://dbgate.org/";
    changelog = "https://github.com/dbgate/dbgate/releases/tag/v${version}";
    license = lib.licenses.mit;
    sourceProvenance = [ lib.sourceTypes.binaryNativeCode ];
    maintainers = with lib.maintainers; [ luftmensch-luftmensch ];

    platforms = [
      "x86_64-linux"
      "aarch64-linux"
      "aarch64-darwin"
    ];

    mainProgram = "dbgate";
  };
in
if stdenv.hostPlatform.isDarwin then
  stdenv.mkDerivation {
    inherit
      pname
      version
      src
      passthru
      meta
      ;

    nativeBuildInputs = [ _7zz ];

    installPhase = ''
      runHook preInstall

      mkdir -p $out/Applications
      cp -r *.app $out/Applications

      runHook postInstall
    '';

    sourceRoot = ".";
    unpackPhase = "7zz x ${src}";
  }
else
  let
    appimageContents = appimageTools.extract { inherit pname src version; };
  in
  appimageTools.wrapType2 {
    inherit
      pname
      version
      src
      passthru
      meta
      ;

    extraInstallCommands = ''
      install -Dm644 ${appimageContents}/dbgate.desktop -t $out/share/applications
      substituteInPlace $out/share/applications/dbgate.desktop \
        --replace-warn "Exec=AppRun --no-sandbox" "Exec=dbgate"
      cp -r ${appimageContents}/usr/share/icons $out/share
    '';
  }
