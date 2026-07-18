{
  lib,
  fetchurl,
  appimageTools,
  gitUpdater,
  makeWrapper,
}:

appimageTools.wrapType2 rec {
  pname = "tutanota-desktop";
  version = "353.260630.0";

  src = fetchurl {
    url = "https://github.com/tutao/tutanota/releases/download/tutanota-desktop-release-${version}/tutanota-desktop-linux.AppImage";
    hash = "sha256-ZJdiufoyZQxZncxyJZd1rhVyBMlkep+8uvchO/D/Krs=";
  };

  nativeBuildInputs = [ makeWrapper ];

  extraInstallCommands =
    let
      appimageContents = appimageTools.extract { inherit pname version src; };
    in
    ''
      install -Dm 444 ${appimageContents}/tutanota-desktop.desktop -t $out/share/applications
      cp -r ${appimageContents}/usr/share/icons/. $out/share/icons

      substituteInPlace $out/share/applications/tutanota-desktop.desktop \
        --replace 'Exec=AppRun' 'Exec=${pname}'

      wrapProgram $out/bin/tutanota-desktop \
        --add-flags "\''${NIXOS_OZONE_WL:+\''${WAYLAND_DISPLAY:+--ozone-platform-hint=auto --enable-features=WaylandWindowDecorations --enable-wayland-ime=true}}"
    '';

  extraPkgs = pkgs: [ pkgs.libsecret ];

  passthru.updateScript = gitUpdater {
    allowedVersions = ".+\\.[0-9]{6}\\..+";
    rev-prefix = "tutanota-desktop-release-";
    url = "https://github.com/tutao/tutanota";
  };

  meta = {
    description = "Tuta official desktop client";
    homepage = "https://tuta.com/";
    changelog = "https://github.com/tutao/tutanota/releases/tag/tutanota-desktop-release-${version}";
    license = lib.licenses.gpl3Only;
    sourceProvenance = with lib.sourceTypes; [ binaryNativeCode ];
    maintainers = with lib.maintainers; [ s0ssh ];
    platforms = [ "x86_64-linux" ];
    mainProgram = "tutanota-desktop";
  };
}
