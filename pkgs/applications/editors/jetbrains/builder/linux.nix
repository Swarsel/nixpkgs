# Linux-specific base builder.

{
  lib,
  stdenv,
  autoPatchelfHook,
  coreutils,
  e2fsprogs,
  excludeDrvArgNames,
  fontconfig,
  git,
  glibcLocales,
  gnugrep,
  jdk,
  libGL,
  libnotify,
  libsecret,
  libx11,
  makeDesktopItem,
  makeWrapper,
  patchelf,
  python3,
  udev,
  unzip,
  which,
  writeText,
  forceWayland ? null,
  vmopts ? null,
}:

lib.extendMkDerivation {
  inherit excludeDrvArgNames;
  constructDrv = stdenv.mkDerivation;

  extendDrvArgs =
    finalAttrs:
    {
      fsnotifier,
      libdbm,
      pname,
      product,
      wmClass,
      buildInputs ? [ ],
      extraLdPath ? [ ],
      extraWrapperArgs ? [ ],
      meta ? { },
      nativeBuildInputs ? [ ],
      postPatch ? "",
      productShort ? product,
      ...
    }:

    let
      loName = lib.toLower productShort;
      hiName = lib.toUpper productShort;
      vmoptsName = loName + lib.optionalString stdenv.hostPlatform.is64bit "64" + ".vmoptions";
      finalExtraWrapperArgs =
        extraWrapperArgs
        ++ lib.optionals forceWayland [
          ''--add-flags "\''${WAYLAND_DISPLAY:+-Dawt.toolkit.name=WLToolkit}"''
        ];

      desktopItem = makeDesktopItem {
        categories = [ "Development" ];
        comment = lib.trim (lib.replaceString "\n" " " finalAttrs.meta.longDescription);
        desktopName = product;
        exec = finalAttrs.meta.mainProgram;
        genericName = finalAttrs.meta.description;
        icon = pname;
        name = finalAttrs.pname;
        startupWMClass = wmClass;
      };

      vmoptsIDE = if hiName == "WEBSTORM" then "WEBIDE" else hiName;
      vmoptsFile = lib.optionalString (vmopts != null) (writeText vmoptsName vmopts);
    in
    {
      inherit desktopItem vmoptsIDE vmoptsFile;

      postPatch = ''
        rm -rf jbr
        # When using the IDE as a remote backend using gateway, it expects the jbr directory to contain the jdk
        ln -s ${jdk.home} jbr

        if [ -d "plugins/remote-dev-server" ]; then
          patch -F3 -p1 < ${../patches/jetbrains-remote-dev.patch}
        fi

        vmopts_file=bin/linux/${vmoptsName}
        if [[ ! -f $vmopts_file ]]; then
          vmopts_file=bin/${vmoptsName}
          if [[ ! -f $vmopts_file ]]; then
            echo "ERROR: $vmopts_file not found"
            exit 1
          fi
        fi
        echo -Djna.library.path=${
          lib.makeLibraryPath [
            libsecret
            e2fsprogs
            libnotify
            # Required for Help -> Collect Logs
            # in at least rider and goland
            udev
          ]
        } >> $vmopts_file
      ''
      + postPatch;

      nativeBuildInputs = nativeBuildInputs ++ [
        makeWrapper
        patchelf
        unzip
        autoPatchelfHook
      ];

      buildInputs = buildInputs ++ [
        stdenv.cc.cc
        fontconfig
        libGL
        libx11
      ];

      installPhase = ''
        runHook preInstall

        mkdir -p $out/{bin,$pname,share/icons/hicolor/scalable/apps,share/icons/hicolor/128x128/apps}
        cp -a . $out/$pname
        [[ -f $out/$pname/bin/${loName}.png ]] && ln -s $out/$pname/bin/${loName}.png $out/share/icons/hicolor/128x128/apps/${pname}.png
        [[ -f $out/$pname/bin/${loName}.svg ]] && ln -s $out/$pname/bin/${loName}.svg $out/share/icons/hicolor/scalable/apps/${pname}.svg
        cp ${libdbm}/lib/libdbm.so $out/$pname/bin/libdbm.so
        cp ${fsnotifier}/bin/fsnotifier $out/$pname/bin/fsnotifier

        jdk=${jdk.home}
        item=${desktopItem}

        needsWrapping=()

        if [ -f "$out/$pname/bin/${loName}" ]; then
          needsWrapping+=("$out/$pname/bin/${loName}")
        fi
        if [ -f "$out/$pname/bin/${loName}.sh" ]; then
          needsWrapping+=("$out/$pname/bin/${loName}.sh")
        fi

        for launcher in "''${needsWrapping[@]}"
        do
          wrapProgram  "$launcher" \
            --prefix PATH : "${
              lib.makeBinPath [
                jdk
                coreutils
                gnugrep
                which
                git
              ]
            }" \
            --suffix PATH : "${lib.makeBinPath [ python3 ]}" \
            --prefix LD_LIBRARY_PATH : "${lib.makeLibraryPath extraLdPath}" \
            ${lib.concatStringsSep " " finalExtraWrapperArgs} \
            --set-default JDK_HOME "$jdk" \
            --set-default ANDROID_JAVA_HOME "$jdk" \
            --set-default JAVA_HOME "$jdk" \
            --set-default JETBRAINS_CLIENT_JDK "$jdk" \
            --set-default ${hiName}_JDK "$jdk" \
            --set-default LOCALE_ARCHIVE "${glibcLocales}/lib/locale/locale-archive" \
            --set-default ${vmoptsIDE}_VM_OPTIONS ${vmoptsFile}
        done

        launcher="$out/$pname/bin/${loName}"
        if [ ! -e "$launcher" ]; then
          launcher+=.sh
        fi

        ln -s "$launcher" $out/bin/$pname
        rm -rf $out/$pname/plugins/remote-dev-server/selfcontained/
        echo -e '#!/usr/bin/env bash\n'"$out/$pname/bin/remote-dev-server.sh"' "$@"' > $out/$pname/bin/remote-dev-server-wrapped.sh
        chmod +x $out/$pname/bin/remote-dev-server-wrapped.sh
        ln -s "$out/$pname/bin/remote-dev-server-wrapped.sh" $out/bin/$pname-remote-dev-server
        ln -s "$item/share/applications" $out/share

        runHook postInstall
      '';

      preferLocalBuild = !(finalAttrs.meta.license.free or true);

      meta = meta // {
        mainProgram = pname;
      };
    };
}
