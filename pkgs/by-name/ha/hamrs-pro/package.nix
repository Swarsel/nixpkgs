{
  lib,
  fetchurl,
  _7zz,
  appimageTools,
  stdenvNoCC,
}:

let
  pname = "hamrs-pro";
  version = "2.47.1";

  throwSystem = throw "Unsupported system: ${stdenvNoCC.hostPlatform.system}";

  srcs = {
    aarch64-darwin = fetchurl {
      hash = "sha256-/9UamFxEJ9NkswgsI8mcfher9nFpVt5Vk0QYFpRXRB4=";
      url = "https://hamrs-dist.s3.amazonaws.com/hamrs-pro-${version}-mac-arm64.dmg";
    };

    aarch64-linux = fetchurl {
      hash = "sha256-5WUQBFyvMHZyyIH2aImCRUYdzou8BadaH/M4+5DeQdo=";
      url = "https://hamrs-dist.s3.amazonaws.com/hamrs-pro-${version}-linux-arm64.AppImage";
    };

    x86_64-linux = fetchurl {
      hash = "sha256-JcckonAYM4HE8yTvzJHJ3pX+H4jOPaUQXaYmWUAg8AY=";
      url = "https://hamrs-dist.s3.amazonaws.com/hamrs-pro-${version}-linux-x86_64.AppImage";
    };
  };

  src = srcs.${stdenvNoCC.hostPlatform.system} or throwSystem;

  passthru.updateScript = ./update.sh;

  meta = {
    description = "Simple, portable logger tailored for activities like Parks on the Air, Field Day, and more";
    homepage = "https://hamrs.app/";
    license = lib.licenses.unfree;
    sourceProvenance = with lib.sourceTypes; [ binaryNativeCode ];

    maintainers = with lib.maintainers; [
      ethancedwards8
      jhollowe
    ];

    platforms = [
      "x86_64-linux"
      "aarch64-linux"
      "aarch64-darwin"
    ];
  };

  linux = appimageTools.wrapType2 rec {
    inherit
      pname
      version
      src
      passthru
      meta
      ;

    extraInstallCommands =
      let
        contents = appimageTools.extract { inherit pname version src; };
      in
      ''
        install -m 444 -D ${contents}/${pname}.desktop -t $out/share/applications
        substituteInPlace $out/share/applications/${pname}.desktop \
          --replace-fail 'Exec=AppRun' 'Exec=${pname}'
        cp -r ${contents}/usr/share/icons $out/share
      '';
  };

  darwin = stdenvNoCC.mkDerivation {
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
  };
in
if stdenvNoCC.hostPlatform.isDarwin then darwin else linux
