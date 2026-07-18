{
  lib,
  stdenv,
  addDriverRunpath,
  appimageTools,
  aprutil,
  bash,
  buildFHSEnv,
  cacert,
  common-updater-scripts,
  copyDesktopItems,
  curl,
  dbus,
  glib,
  jq,
  libGLU,
  libarchive,
  libice,
  libsm,
  libx11,
  libxcb,
  libxcb-image,
  libxcb-keysyms,
  libxcb-render-util,
  libxcb-util,
  libxcb-wm,
  libxcomposite,
  libxcrypt,
  libxcursor,
  libxdamage,
  libxext,
  libxfixes,
  libxi,
  libxinerama,
  libxrandr,
  libxrender,
  libxt,
  libxtst,
  libxxf86vm,
  makeDesktopItem,
  ocl-icd,
  python3,
  runCommandLocal,
  unzip,
  writeShellApplication,
  writeShellScript,
  writeText,
  xkeyboard-config,
  xkeyboard_config,
  studioVariant ? false,
}:

let
  davinci = (
    stdenv.mkDerivation rec {
      pname = "davinci-resolve${lib.optionalString studioVariant "-studio"}";
      version = "21.0.1";

      src =
        runCommandLocal "${pname}-src.zip"
          rec {
            DOWNLOADSURL = "https://www.blackmagicdesign.com/api/support/us/downloads.json";
            PRODUCT = "DaVinci Resolve${lib.optionalString studioVariant " Studio"}";
            # Get linux.downloadId from HTTP response on https://www.blackmagicdesign.com/products/davinciresolve
            REFERID = "263d62f31cbb49e0868005059abcb0c9";

            REQJSON = builtins.toJSON {
              "city" = "Utrecht";
              "country" = "nl";
              "email" = "someone@nixos.org";
              "firstname" = "NixOS";
              "lastname" = "Linux";
              "phone" = "+31 71 452 5670";
              "product" = PRODUCT;
              "state" = "Province of Utrecht";
              "street" = "-";
            };

            SITEURL = "https://www.blackmagicdesign.com/api/register/us/download";
            # ENV VARS
            SSL_CERT_FILE = "${cacert}/etc/ssl/certs/ca-bundle.crt";

            USERAGENT = builtins.concatStringsSep " " [
              "User-Agent: Mozilla/5.0 (X11; Linux ${stdenv.hostPlatform.linuxArch})"
              "AppleWebKit/537.36 (KHTML, like Gecko)"
              "Chrome/77.0.3865.75"
              "Safari/537.36"
            ];

            VERSION = version;
            impureEnvVars = lib.fetchers.proxyImpureEnvVars;

            nativeBuildInputs = [
              curl
              jq
            ];

            outputHash =
              if studioVariant then
                "sha256-8JN3ptd8jcacxHihZHXuhdkyambUsnFIj+AruvpztKI="
              else
                "sha256-ioAqvqHjwFX1ec6fDoxg2VUZy1moYoGx/aEewDuN1+g=";

            outputHashAlgo = "sha256";
            outputHashMode = "recursive";

          }
          ''
            DOWNLOADID=$(
              curl --silent --compressed "$DOWNLOADSURL" \
                | jq --raw-output '.downloads[] | .urls.Linux?[]? | select(.downloadTitle | test("^'"$PRODUCT $VERSION"'( Update)?$")) | .downloadId'
            )
            echo "downloadid is $DOWNLOADID"
            test -n "$DOWNLOADID"
            RESOLVEURL=$(curl \
              --silent \
              --header 'Host: www.blackmagicdesign.com' \
              --header 'Accept: application/json, text/plain, */*' \
              --header 'Origin: https://www.blackmagicdesign.com' \
              --header "$USERAGENT" \
              --header 'Content-Type: application/json;charset=UTF-8' \
              --header "Referer: https://www.blackmagicdesign.com/support/download/$REFERID/Linux" \
              --header 'Accept-Encoding: gzip, deflate, br' \
              --header 'Accept-Language: en-US,en;q=0.9' \
              --header 'Authority: www.blackmagicdesign.com' \
              --header 'Cookie: _ga=GA1.2.1849503966.1518103294; _gid=GA1.2.953840595.1518103294' \
              --data-ascii "$REQJSON" \
              --compressed \
              "$SITEURL/$DOWNLOADID")
            echo "resolveurl is $RESOLVEURL"

            curl \
              --retry 3 --retry-delay 3 \
              --header "Upgrade-Insecure-Requests: 1" \
              --header "$USERAGENT" \
              --header "Accept: text/html,application/xhtml+xml,application/xml;q=0.9,image/webp,image/apng,*/*;q=0.8" \
              --header "Accept-Language: en-US,en;q=0.9" \
              --compressed \
              "$RESOLVEURL" \
              > $out
          '';

      nativeBuildInputs = [
        appimageTools.appimage-exec
        addDriverRunpath
        copyDesktopItems
        unzip
      ];

      # Pretty sure, there are missing dependencies ...
      buildInputs = [
        libGLU
        libxxf86vm
      ];

      installPhase =
        let
          appimageName = "DaVinci_Resolve_${lib.optionalString studioVariant "Studio_"}${version}_Linux.run";
        in
        ''
          runHook preInstall

          export HOME=$PWD/home
          mkdir -p $HOME

          mkdir -p $out
          test -e ${lib.escapeShellArg appimageName}
          appimage-exec.sh -x $out ${lib.escapeShellArg appimageName}

          mkdir -p $out/{"Apple Immersive/Calibration",configs,DolbyVision,easyDCP,Extras,Fairlight,GPUCache,logs,Media,"Resolve Disk Database",.crashreport,.license,.LUT}

          # Install udev rules for Blackmagic hardware (color panels, Speed Editor, Editor Keyboard)
          mkdir -p $out/lib/udev/rules.d
          cp $out/share/etc/udev/rules.d/99-BlackmagicDevices.rules $out/lib/udev/rules.d/
          cp $out/share/etc/udev/rules.d/99-ResolveKeyboardHID.rules $out/lib/udev/rules.d/
          # Generate catch-all rules for Blackmagic Design vendor ID (096e)
          # USB device access (color panels, general hardware)
          echo 'SUBSYSTEM=="usb", ENV{DEVTYPE}=="usb_device", ATTRS{idVendor}=="096e", MODE="0666"' \
            > $out/lib/udev/rules.d/99-DavinciPanel.rules
          # hidraw access (Speed Editor jog wheel, Editor Keyboard, future HID devices)
          echo 'KERNEL=="hidraw*", SUBSYSTEM=="hidraw", ATTRS{idVendor}=="096e", MODE="0666"' \
            >> $out/lib/udev/rules.d/99-DavinciPanel.rules

          # Verify all three rules files are present
          test -f $out/lib/udev/rules.d/99-BlackmagicDevices.rules
          test -f $out/lib/udev/rules.d/99-ResolveKeyboardHID.rules
          test -f $out/lib/udev/rules.d/99-DavinciPanel.rules
          runHook postInstall
        '';

      postFixup = ''
        for program in $out/bin/*; do
          isELF "$program" || continue
          addDriverRunpath "$program"
        done

        for program in $out/libs/*; do
          isELF "$program" || continue
          if [[ "$program" != *"libcudnn_cnn_infer"* ]];then
            echo $program
            addDriverRunpath "$program"
          fi
        done
        ln -s $out/libs/libcrypto.so.1.1 $out/libs/libcrypt.so.1
      '';

      desktopItems = [
        (makeDesktopItem {
          categories = [
            "AudioVideo"
            "AudioVideoEditing"
            "Video"
            "Graphics"
          ];

          comment = "Professional video editing, color, effects and audio post-processing";
          desktopName = "Davinci Resolve${lib.optionalString studioVariant " Studio"}";
          exec = "davinci-resolve${lib.optionalString studioVariant "-studio"}";
          genericName = "Video Editor";
          icon = "davinci-resolve${lib.optionalString studioVariant "-studio"}";
          name = "davinci-resolve${lib.optionalString studioVariant "-studio"}";
          startupWMClass = "resolve";
        })
        (makeDesktopItem {
          categories = [
            "Video"
            "AudioVideo"
          ];

          desktopName = "Blackmagic RAW Player";
          exec = "blackmagicraw-player %f";
          icon = "blackmagicraw-player";

          mimeTypes = [
            "application/x-braw-clip"
            "application/x-braw-sidecar"
          ];

          name = "blackmagicraw-player";
        })
        (makeDesktopItem {
          categories = [
            "Video"
            "AudioVideo"
          ];

          desktopName = "Blackmagic RAW Speed Test";
          exec = "blackmagicraw-speedtest";
          icon = "blackmagicraw-speedtest";
          name = "blackmagicraw-speedtest";
        })
        (makeDesktopItem {
          categories = [ "Settings" ];
          desktopName = "DaVinci Control Panels Setup";
          exec = "davinci-control-panels-setup";
          icon = "davinci-control-panels-setup";
          name = "davinci-control-panels-setup";
        })
        (makeDesktopItem {
          categories = [
            "AudioVideo"
            "Audio"
          ];

          desktopName = "Fairlight Studio Utility";
          exec = "davinci-fairlight-studio-utility";
          icon = "davinci-resolve${lib.optionalString studioVariant "-studio"}";
          name = "davinci-fairlight-studio-utility";
        })
      ]
      ++ lib.optional studioVariant (makeDesktopItem {
        categories = [
          "AudioVideo"
          "Video"
        ];

        comment = "DaVinci Remote Monitor";
        desktopName = "DaVinci Remote Monitor";
        exec = "davinci-remote-monitor";
        icon = "davinci-remote-monitor";
        name = "davinci-remote-monitor";
      });

      dontStrip = true;
      # The unpack phase won't generate a directory
      sourceRoot = ".";
    }
  );
in
buildFHSEnv {
  inherit (davinci) pname version;

  extraBwrapArgs = lib.optionals studioVariant [
    ''--bind "$HOME"/.local/share/DaVinciResolve/license ${davinci}/.license''
    ''--bind "$HOME"/.local/share/DaVinciResolve/Extras ${davinci}/Extras''
  ];

  extraInstallCommands =
    let
      execName = "davinci-resolve${lib.optionalString studioVariant "-studio"}";
      # Each wrapper re-enters the FHS environment and execs a different binary
      mkWrapper =
        name: bin:
        writeShellScript name ''
          exec "$(dirname "$0")/${execName}" ${bin} "$@"
        '';
      wrappers = {
        "blackmagicraw-player" = "${davinci}/BlackmagicRAWPlayer/BlackmagicRAWPlayer";
        "blackmagicraw-speedtest" = "${davinci}/BlackmagicRAWSpeedTest/BlackmagicRAWSpeedTest";

        "davinci-control-panels-setup" =
          ''"${davinci}/DaVinci Control Panels Setup/DaVinci Control Panels Setup"'';

        "davinci-fairlight-studio-utility" =
          ''"${davinci}/Fairlight Studio Utility/Fairlight Studio Utility"'';
      }
      // lib.optionalAttrs studioVariant {
        "davinci-remote-monitor" = ''"${davinci}/bin/DaVinci Remote Monitor"'';
      };
    in
    ''
      # Desktop files
      mkdir -p $out/share/applications
      ln -s ${davinci}/share/applications/*.desktop $out/share/applications/

      # Icons
      mkdir -p $out/share/icons/hicolor/{128x128,256x256}/apps
      ln -s ${davinci}/graphics/DV_Resolve.png $out/share/icons/hicolor/128x128/apps/davinci-resolve${lib.optionalString studioVariant "-studio"}.png
      ln -s ${davinci}/graphics/DV_Panels.png $out/share/icons/hicolor/128x128/apps/davinci-control-panels-setup.png
      ${lib.optionalString studioVariant ''
        ln -s ${davinci}/graphics/Remote_Monitoring.png $out/share/icons/hicolor/128x128/apps/davinci-remote-monitor.png
      ''}
      ln -s ${davinci}/graphics/blackmagicraw-player_256x256_apps.png $out/share/icons/hicolor/256x256/apps/blackmagicraw-player.png
      ln -s ${davinci}/graphics/blackmagicraw-speedtest_256x256_apps.png $out/share/icons/hicolor/256x256/apps/blackmagicraw-speedtest.png

      # Wrapper scripts for additional programs
      ${lib.concatStringsSep "\n" (
        lib.mapAttrsToList (name: bin: ''
          ln -s ${mkWrapper name bin} $out/bin/${name}
        '') wrappers
      )}

      # MIME type definitions for .drp, .braw, etc.
      mkdir -p $out/share/mime/packages
      ln -s ${davinci}/share/resolve.xml $out/share/mime/packages/
      ln -s ${davinci}/share/blackmagicraw.xml $out/share/mime/packages/

      # Expose udev rules so NixOS can aggregate them from environment.systemPackages
      mkdir -p $out/lib/udev/rules.d
      ln -s ${davinci}/lib/udev/rules.d/99-BlackmagicDevices.rules $out/lib/udev/rules.d/
      ln -s ${davinci}/lib/udev/rules.d/99-ResolveKeyboardHID.rules $out/lib/udev/rules.d/
      ln -s ${davinci}/lib/udev/rules.d/99-DavinciPanel.rules $out/lib/udev/rules.d/
    '';

  extraPreBwrapCmds = lib.optionalString studioVariant ''
    mkdir -p ~/.local/share/DaVinciResolve/license || exit 1
    mkdir -p ~/.local/share/DaVinciResolve/Extras || exit 1
  '';

  runScript = "${bash}/bin/bash ${writeText "davinci-wrapper" ''
    export QT_XKB_CONFIG_ROOT="${xkeyboard_config}/share/X11/xkb"
    export QT_PLUGIN_PATH="${davinci}/libs/plugins:$QT_PLUGIN_PATH"
    export LD_LIBRARY_PATH=$LD_LIBRARY_PATH:/usr/lib:/usr/lib32:${davinci}/libs
    if [ $# -gt 0 ]; then
      exec "$@"
    else
      exec ${davinci}/bin/resolve
    fi
  ''}";

  targetPkgs =
    pkgs: with pkgs; [
      alsa-lib
      aprutil
      bzip2
      davinci
      dbus
      expat
      fontconfig
      freetype
      glib
      libGL
      libGLU
      libarchive
      libcap
      librsvg
      libtool
      libuuid
      libxcrypt # provides libcrypt.so.1
      libxkbcommon
      nspr
      ocl-icd
      opencl-headers
      python3
      python3.pkgs.numpy
      libdrm # libdrm.so.2 needed by bundled Qt6 WebEngine (Control Panels Setup)
      libxkbfile # libxkbfile.so.1 needed by bundled Qt6 WebEngine (Control Panels Setup)
      krb5 # libgssapi_krb5.so.2 needed by bundled Qt6 (Control Panels Setup, Fairlight Studio Utility)
      nss # libsmime3.so needed by bundled Qt6 (Control Panels Setup)
      libxcb-cursor # libxcb-cursor.so needed by Qt6 xcb platform plugin (Fairlight Studio Utility)
      udev
      xdg-utils # xdg-open needed to open URLs
      libice
      libsm
      libx11
      libxcomposite
      libxcursor
      libxdamage
      libxext
      libxfixes
      libxi
      libxinerama
      libxrandr
      libxrender
      libxt
      libxtst
      libxxf86vm
      libxcb
      libxcb-util
      libxcb-image
      libxcb-keysyms
      libxcb-render-util
      libxcb-wm
      xkeyboard-config
      zlib
    ];

  passthru = {
    inherit davinci;
  }
  // lib.optionalAttrs (!studioVariant) {
    updateScript = lib.getExe (writeShellApplication {
      name = "update-davinci-resolve";

      runtimeInputs = [
        curl
        jq
        common-updater-scripts
      ];

      text = ''
        set -o errexit
        drv=pkgs/by-name/da/davinci-resolve/package.nix
        currentVersion=${lib.escapeShellArg davinci.version}
        downloadsJSON="$(curl --fail --silent https://www.blackmagicdesign.com/api/support/us/downloads.json)"

        latestLinuxVersion="$(echo "$downloadsJSON" | jq '[.downloads[] | select(.urls.Linux) | .urls.Linux[] | select(.downloadTitle | test("DaVinci Resolve")) | .downloadTitle]' | grep -oP 'DaVinci Resolve \K\d+\.\d+(\.\d+)?' | sort | tail -n 1)"
        update-source-version davinci-resolve "$latestLinuxVersion" --source-key=davinci.src

        # Since the standard and studio both use the same version we need to reset it before updating studio
        sed -i -e "s/""$latestLinuxVersion""/""$currentVersion""/" "$drv"

        latestStudioLinuxVersion="$(echo "$downloadsJSON" | jq '[.downloads[] | select(.urls.Linux) | .urls.Linux[] | select(.downloadTitle | test("DaVinci Resolve")) | .downloadTitle]' | grep -oP 'DaVinci Resolve Studio \K\d+\.\d+(\.\d+)?' | sort | tail -n 1)"
        update-source-version davinci-resolve-studio "$latestStudioLinuxVersion" --source-key=davinci.src
      '';
    });
  };

  meta = {
    description = "Professional video editing, color, effects and audio post-processing";
    homepage = "https://www.blackmagicdesign.com/products/davinciresolve";
    license = lib.licenses.unfree;
    sourceProvenance = with lib.sourceTypes; [ binaryNativeCode ];

    maintainers = with lib.maintainers; [
      amarshall
      XBagon
      toXel
      cafkafk
    ];

    platforms = [ "x86_64-linux" ];
    mainProgram = "davinci-resolve${lib.optionalString studioVariant "-studio"}";
  };
}
