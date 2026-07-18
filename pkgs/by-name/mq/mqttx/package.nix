{
  lib,
  stdenv,
  fetchurl,
  appimageTools,
  imagemagick,
}:

let
  pname = "mqttx";
  version = "1.12.1";

  suffixedUrl =
    suffix:
    "https://github.com/emqx/MQTTX/releases/download/v${version}/MQTTX-${version}${suffix}.AppImage";
  sources = {
    "aarch64-linux" = fetchurl {
      hash = "sha256-IfxPrr4VjSGFOWjrpiwwq9OKQ33J1YIJKK0ILF9nTXw=";
      url = suffixedUrl "-arm64";
    };

    "x86_64-linux" = fetchurl {
      hash = "sha256-TUtW2heIjTB+mb8U8v90Saz98alha3aFjqHotWW4tgw=";
      url = suffixedUrl "";
    };
  };

  src =
    sources.${stdenv.hostPlatform.system}
      or (throw "Unsupported system: ${stdenv.hostPlatform.system}");

  appimageContents = appimageTools.extractType2 {
    inherit pname version src;
  };
in
appimageTools.wrapType2 {
  inherit pname version src;

  extraInstallCommands = ''
    install -m 444 -D ${appimageContents}/${pname}.desktop $out/share/applications/${pname}.desktop
    install -m 444 -D ${appimageContents}/${pname}.png $out/share/icons/hicolor/1024x1024/apps/${pname}.png

    ${imagemagick}/bin/convert ${appimageContents}/mqttx.png -resize 512x512 ${pname}_512.png
    install -m 444 -D ${pname}_512.png $out/share/icons/hicolor/512x512/apps/${pname}.png

    substituteInPlace $out/share/applications/${pname}.desktop \
      --replace-fail 'Exec=AppRun' 'Exec=${pname}'
  '';

  extraPkgs = pkgs: [ pkgs.libxshmfence ];

  meta = {
    description = "Powerful cross-platform MQTT 5.0 Desktop, CLI, and WebSocket client tools";
    homepage = "https://mqttx.app/";
    changelog = "https://github.com/emqx/MQTTX/releases/tag/v${version}";
    license = lib.licenses.asl20;
    maintainers = [ ];
    platforms = lib.platforms.linux;
    mainProgram = "mqttx";
  };
}
