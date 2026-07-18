{
  lib,
  fetchurl,
  appimageTools,
  makeWrapper,
}:

let
  pname = "notable";
  version = "1.8.4";
  sha256 = "0rvz8zwsi62kiq89pv8n2wh9h5yb030kvdr1vf65xwqkhqcrzrby";

  src = fetchurl {
    inherit sha256;
    url = "https://github.com/notable/notable/releases/download/v${version}/Notable-${version}.AppImage";
  };

  appimageContents = appimageTools.extract {
    inherit pname version src;
  };
in
appimageTools.wrapType2 {

  inherit pname version src;
  nativeBuildInputs = [ makeWrapper ];

  extraInstallCommands = ''
    install -m 444 -D ${appimageContents}/notable.desktop $out/share/applications/notable.desktop
    for size in 16 32 48 64 128 256 512; do
      install -m 444 -D ${appimageContents}/usr/share/icons/hicolor/''${size}x''${size}/apps/notable.png \
        $out/share/icons/hicolor/''${size}x''${size}/apps/notable.png
    done
    install -m 444 -D ${appimageContents}/usr/share/icons/hicolor/1024x1024/apps/notable.png \
      $out/share/icons/notable.png
    substituteInPlace $out/share/applications/notable.desktop \
      --replace-fail 'Exec=AppRun' 'Exec=notable'
    wrapProgram "$out/bin/notable" \
      --add-flags "--disable-seccomp-filter-sandbox"
  '';

  extraPkgs = pkgs: [
    pkgs.at-spi2-atk
    pkgs.at-spi2-core
  ];

  profile = ''
    export LC_ALL=C.UTF-8
  '';

  meta = {
    description = "Markdown-based note-taking app that doesn't suck";
    homepage = "https://github.com/notable/notable";
    license = lib.licenses.unfree;
    maintainers = [ ];
    platforms = [ "x86_64-linux" ];
  };
}
