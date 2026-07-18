{
  lib,
  stdenv,
  fetchurl,
  appimageTools,
  undmg,
}:
let
  pname = "insomnia";
  version = "13.0.0";

  src =
    fetchurl
      {
        aarch64-darwin = {
          hash = "sha256-sPl7KXC8Z13LFZvxuKg02iDbtrCxn//Yrr8AOOf3VD4=";
          url = "https://github.com/Kong/insomnia/releases/download/core%40${version}/Insomnia.Core-${version}.dmg";
        };

        x86_64-linux = {
          hash = "sha256-PlcKBQnkmgU/SsLRKX7ohrGHm7B4hK9FMkplwlbFolI=";
          url = "https://github.com/Kong/insomnia/releases/download/core%40${version}/Insomnia.Core-${version}.AppImage";
        };
      }
      .${stdenv.system} or (throw "Unsupported system: ${stdenv.system}");

  meta = {
    description = "Open-source, cross-platform API client for GraphQL, REST, WebSockets, SSE and gRPC, with Cloud, Local and Git storage";
    homepage = "https://insomnia.rest";
    changelog = "https://github.com/Kong/insomnia/releases/tag/core@${version}";
    license = lib.licenses.asl20;

    maintainers = with lib.maintainers; [
      markus1189
      kashw2
      DataHearth
    ];

    platforms = [
      "aarch64-darwin"
      "x86_64-linux"
    ];

    mainProgram = "insomnia";
  };
in
if stdenv.hostPlatform.isDarwin then
  stdenv.mkDerivation {
    inherit
      pname
      version
      src
      meta
      ;

    nativeBuildInputs = [ undmg ];

    installPhase = ''
      runHook preInstall
      mkdir -p "$out/Applications"
      mv Insomnia.app $out/Applications/
      runHook postInstall
    '';

    sourceRoot = ".";
  }
else
  appimageTools.wrapType2 {
    inherit
      pname
      version
      src
      meta
      ;

    extraInstallCommands =
      let
        appimageContents = appimageTools.extract {
          inherit pname version src;
        };
      in
      ''
        # Install XDG Desktop file and its icon
        install -Dm444 ${appimageContents}/insomnia.desktop -t $out/share/applications
        install -Dm444 ${appimageContents}/insomnia.png -t $out/share/icons/
        # Replace wrong exec statement in XDG Desktop file
        substituteInPlace $out/share/applications/insomnia.desktop \
            --replace-fail 'Exec=AppRun --no-sandbox %U' 'Exec=insomnia'
      '';
  }
