{
  lib,
  fetchurl,
  appimageTools,
  makeWrapper,
  nix-update-script,
  stdenvNoCC,
  undmg,
}:

let
  pname = "electron-mail";
  version = "5.3.8";

  sources = {
    aarch64-darwin = fetchurl {
      hash = "sha256-V32Wi0oCU9dLfzqxg3OdseiILX7wPiBGNz7KuG0vlZY=";
      url = "https://github.com/vladimiry/ElectronMail/releases/download/v${version}/electron-mail-${version}-mac-arm64.dmg";
    };

    x86_64-linux = fetchurl {
      hash = "sha256-twqB1D3zLlZJuxQWD4dGF70w57yYv6i3abGBidERsss=";
      url = "https://github.com/vladimiry/ElectronMail/releases/download/v${version}/electron-mail-${version}-linux-x86_64.AppImage";
    };
  };

  src = sources.${stdenvNoCC.hostPlatform.system};

  appimageContents = appimageTools.extract {
    inherit src pname version;
  };

  meta = {
    description = "Unofficial Election-based ProtonMail desktop client";
    homepage = "https://github.com/vladimiry/ElectronMail";
    changelog = "https://github.com/vladimiry/ElectronMail/releases/tag/v${version}";
    license = lib.licenses.gpl3;

    maintainers = with lib.maintainers; [
      princemachiavelli
      BatteredBunny
    ];

    platforms = [
      "x86_64-linux"
      "aarch64-darwin"
    ];

    mainProgram = "electron-mail";
  };

  linux = appimageTools.wrapType2 {
    inherit
      src
      pname
      version
      meta
      ;

    extraInstallCommands = ''
      install -m 444 -D ${appimageContents}/${pname}.desktop -t $out/share/applications
      substituteInPlace $out/share/applications/${pname}.desktop \
        --replace-fail 'Exec=AppRun' 'Exec=${pname}'
      cp -r ${appimageContents}/usr/share/icons $out/share
    '';

    extraPkgs = pkgs: [
      pkgs.libsecret
      pkgs.libappindicator-gtk3
    ];

    passthru.updateScript = nix-update-script { };
  };

  darwin = stdenvNoCC.mkDerivation {
    inherit
      src
      pname
      version
      meta
      ;

    nativeBuildInputs = [
      undmg
      makeWrapper
    ];

    installPhase = ''
      runHook preInstall

      mkdir -p $out/Applications
      cp -r *.app $out/Applications/
      makeWrapper "$out/Applications/electron-mail.app/Contents/MacOS/electron-mail" $out/bin/${pname}

      runHook postInstall
    '';

    sourceRoot = ".";
  };
in
if stdenvNoCC.hostPlatform.isDarwin then darwin else linux
