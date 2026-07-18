{
  lib,
  stdenv,
  fetchurl,
  _7zz,
  appimageTools,
  jdk21,
}:
let
  pname = "nosql-workbench";
  version = "3.20.2";

  src =
    fetchurl
      {
        aarch64-darwin = {
          hash = "sha256-U6Gea89/cXY9Fd6JAWrUtf7Q4VfEXDPzbjCQcHMRjiE=";
          url = "https://s3.amazonaws.com/nosql-workbench/NoSQL%20Workbench-mac-arm64-${version}.dmg";
        };

        x86_64-linux = {
          hash = "sha256-O62JsVHJ5OE6HLt3Pg9XVrd3j1eoY3O+bjqroowGEOE=";
          url = "https://s3.amazonaws.com/nosql-workbench/NoSQL%20Workbench-linux-${version}.AppImage";
        };
      }
      .${stdenv.system} or (throw "Unsupported system: ${stdenv.system}");

  meta = {
    description = "Visual tool that provides data modeling, data visualization, and query development features to help you design, create, query, and manage DynamoDB tables";
    homepage = "https://docs.aws.amazon.com/amazondynamodb/latest/developerguide/workbench.html";
    changelog = "https://docs.aws.amazon.com/amazondynamodb/latest/developerguide/WorkbenchDocumentHistory.html";
    license = lib.licenses.unfree;
    maintainers = with lib.maintainers; [ DataHearth ];

    platforms = [
      "aarch64-darwin"
      "x86_64-linux"
    ];
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

    # DMG file is using APFS which is unsupported by "undmg".
    # Instead, use "7zz" to extract the contents.
    # "undmg" issue: https://github.com/matthewbauer/undmg/issues/4
    nativeBuildInputs = [ _7zz ];
    buildInputs = [ jdk21 ];

    installPhase = ''
      runHook preInstall

      mkdir -p "$out/Applications"
      mv NoSQL\ Workbench.app $out/Applications/

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
        appimageContents = appimageTools.extract { inherit pname version src; };
        internal_filename = "@amznnosql-workbench";
      in
      ''
        # Install XDG Desktop file and its icon
        install -Dm444 ${appimageContents}/${internal_filename}.desktop -t $out/share/applications
        install -Dm444 ${appimageContents}/${internal_filename}.png -t $out/share/icons/hicolor/512x512/apps

        # Replace wrong exec statement in XDG Desktop file
        substituteInPlace $out/share/applications/${internal_filename}.desktop \
            --replace-fail 'Exec=AppRun --no-sandbox %U' 'Exec=nosql-workbench'
      '';

    extraPkgs = pkgs: [
      # Required to run DynamoDB locally
      pkgs.jdk21
    ];
  }
