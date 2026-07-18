{
  lib,
  stdenv,
  fetchurl,
  appimageTools,
  undmg,
}:

let
  pname = "hoppscotch";
  version = "26.5.0-0";

  src =
    fetchurl
      {
        aarch64-darwin = {
          hash = "sha256-RnLMpXkDAk89T5ogNiVz8zMMdLtXTlAg5nu+sjyczEk=";
          url = "https://github.com/hoppscotch/releases/releases/download/v${version}/Hoppscotch_mac_aarch64.dmg";
        };

        x86_64-linux = {
          hash = "sha256-irPI613Y1l0j5F+Nzm9v/JXsiJY35D8dQpmMcPMYvmU=";
          url = "https://github.com/hoppscotch/releases/releases/download/v${version}/Hoppscotch_linux_x64.AppImage";
        };
      }
      .${stdenv.hostPlatform.system} or (throw "Unsupported system: ${stdenv.hostPlatform.system}");

  passthru.updateScript = ./update.sh;

  meta = {
    description = "Open source API development ecosystem";

    longDescription = ''
      Hoppscotch is a lightweight, web-based API development suite. It was built
      from the ground up with ease of use and accessibility in mind providing
      all the functionality needed for API developers with minimalist,
      unobtrusive UI.
    '';

    homepage = "https://hoppscotch.com";
    changelog = "https://github.com/hoppscotch/hoppscotch/releases/tag/20${lib.head (lib.splitString "-" version)}";
    license = lib.licenses.mit;
    sourceProvenance = [ lib.sourceTypes.binaryNativeCode ];
    maintainers = with lib.maintainers; [ DataHearth ];

    platforms = [
      "aarch64-darwin"
      "x86_64-linux"
    ];

    mainProgram = "hoppscotch";
    downloadPage = "https://hoppscotch.com/downloads";
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

    nativeBuildInputs = [ undmg ];

    installPhase = ''
      runHook preInstall

      mkdir -p "$out/Applications"
      mv Hoppscotch.app $out/Applications/

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
      passthru
      meta
      ;

    extraInstallCommands =
      let
        appimageContents = appimageTools.extractType2 { inherit pname version src; };
      in
      ''
        # Install .desktop files
        install -Dm444 ${appimageContents}/Hoppscotch.desktop $out/share/applications/hoppscotch.desktop
        install -Dm444 ${appimageContents}/Hoppscotch.png $out/share/icons/hicolor/256x256/apps/hoppscotch.png
        substituteInPlace $out/share/applications/hoppscotch.desktop \
          --replace-fail "hoppscotch-desktop" "hoppscotch"
      '';
  }
