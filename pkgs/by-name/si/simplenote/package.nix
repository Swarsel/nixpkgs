{
  lib,
  fetchurl,
  appimageTools,
  makeDesktopItem,
  nix-update-script,
}:

let
  pname = "simplenote";
  version = "2.27.1";

  src = fetchurl {
    url = "https://github.com/Automattic/simplenote-electron/releases/download/v${version}/Simplenote-linux-${version}-x86_64.AppImage";
    hash = "sha512-jf9mnmf+5Xcowxgx7uizWVmv88gPdYwojQ2f+xhbqnXaHD3dSbcW2YdxiV3qjmFsRzUgwZvBVOGpOMvnSHuQDA==";
  };

  appimageContents = appimageTools.extract { inherit pname version src; };
in
appimageTools.wrapType2 {
  inherit pname version src;
  strictDeps = true;
  __structuredAttrs = true;

  desktopItems = [
    (makeDesktopItem {
      categories = [ "Utility" ];
      comment = "Simplenote for Linux";
      exec = pname;
      genericName = "Note Taking Application";
      icon = "simplenote";
      name = pname;
      startupNotify = true;
    })
  ];

  extraInstallCommands = ''
    install -m 444 -D ${appimageContents}/${pname}.desktop -t $out/share/applications
    substituteInPlace $out/share/applications/${pname}.desktop \
      --replace-fail 'Exec=AppRun' 'Exec=${pname}'

    cp -r ${appimageContents}/usr/share/icons $out/share
  '';

  extraPkgs =
    pkgs: with pkgs; [
      libsecret
      libnotify
      libappindicator-gtk3
    ];

  passthru.updateScript = nix-update-script { };

  meta = {
    description = "The simplest way to keep notes";
    homepage = "https://github.com/Automattic/simplenote-electron";
    changelog = "https://github.com/Automattic/simplenote-electron/releases/tag/v${version}/RELEASE-NOTES.md";
    license = lib.licenses.gpl2Plus;
    maintainers = with lib.maintainers; [ _2zqa ];
    platforms = [ "x86_64-linux" ];
    mainProgram = "simplenote";
  };
}
