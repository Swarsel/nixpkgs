{
  lib,
  fetchurl,
  appimageTools,
  asar,
  python3,
}:
let
  pname = "flexoptix-app";
  version = "5.57.0-latest";

  src = fetchurl {
    url = "https://flexbox.reconfigure.me/download/electron/linux/x64/FLEXOPTIX%20App.${version}.AppImage";
    hash = "sha256-wTrvteIXiCMk4y2JnXodn5o89XJrLGHxOpHmma4SQXY=";
    name = "${pname}-${version}.AppImage";
  };

  udevRules = fetchurl {
    hash = "sha256-/1ZtJT+1IMyYqw3N0bVJ/T3vbmex169lzx+SlY5WsnA=";
    url = "https://www.flexoptix.net/static/frontend/Flexoptix/default/en_US/files/99-tprogrammer.rules";
  };

  appimageContents = (appimageTools.extract { inherit pname version src; }).overrideAttrs (old: {
    buildCommand = ''
      ${old.buildCommand}

      # Remove left-over node-gyp executable symlinks
      # https://github.com/nodejs/node-gyp/issues/2713
      find $out/ -type l -name python3 -exec ln -sf ${python3.interpreter} {} \;

      # Extract app to make it patchable
      ${asar}/bin/asar extract $out/resources/app.asar app

      # Fix app crash when none of these secret managers is available: https://www.electronjs.org/docs/latest/api/safe-storage#safestoragegetselectedstoragebackend-linux
      patch -p0 < ${./allow-no-secret-manager.patch}
      # Get rid of the autoupdater
      patch -p0 < ${./disable-autoupdate.patch}

      # Makes debugging easier: cp -r app $out/_app

      # Repackage
      ${asar}/bin/asar pack app $out/resources/app.asar
    '';
  });

in
appimageTools.wrapAppImage {
  inherit pname version;
  src = appimageContents;

  extraInstallCommands = ''
    # Add desktop convencience stuff
    install -Dm444 ${appimageContents}/flexoptix-app.desktop -t $out/share/applications
    install -Dm444 ${appimageContents}/flexoptix-app.png -t $out/share/pixmaps
    substituteInPlace $out/share/applications/flexoptix-app.desktop \
      --replace-fail 'Exec=AppRun' "Exec=$out/bin/${pname} --"

    # For debugging
    [[ -e ${appimageContents}/_app ]] && ln -s ${appimageContents}/_app $out

    # Add udev rules
    mkdir -p $out/lib/udev/rules.d
    ln -s ${udevRules} $out/lib/udev/rules.d/99-tprogrammer.rules
  '';

  extraPkgs = pkgs: [ pkgs.hidapi ];

  meta = {
    description = "Configure FLEXOPTIX Universal Transceivers in seconds";
    homepage = "https://www.flexoptix.net";
    changelog = "https://www.flexoptix.net/en/flexoptix-app/?os=linux#flexapp__modal__changelog";
    license = lib.licenses.unfree;

    maintainers = with lib.maintainers; [
      das_j
      helsinki-Jo
    ];

    platforms = [ "x86_64-linux" ];
  };
}
