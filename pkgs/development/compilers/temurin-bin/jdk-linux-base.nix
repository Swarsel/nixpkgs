{
  sourcePerArch,
  brand-name ? "Eclipse Temurin",
  knownVulnerabilities ? [ ],
  name-prefix ? "temurin",
}:

{
  lib,
  stdenv,
  fetchurl,
  # minimum dependencies
  alsa-lib,
  autoPatchelfHook,
  cairo,
  # runtime dependencies
  cups,
  fontconfig,
  freetype,
  glib,
  gtk3,
  libffi,
  libx11,
  libxext,
  libxi,
  libxrender,
  libxtst,
  makeWrapper,
  setJavaClassPath,
  zlib,
  # runtime dependencies for GTK+ Look and Feel
  # TODO(@sternenseemann): gtk3 fails to evaluate in pkgsCross.ghcjs.buildPackages
  # which should be fixable, this is a no-rebuild workaround for GHC.
  gtkSupport ? !stdenv.targetPlatform.isGhcjs,
}:

let
  cpuName = stdenv.hostPlatform.parsed.cpu.name;
  runtimeDependencies = [
    cups
  ]
  ++ lib.optionals gtkSupport [
    cairo
    glib
    gtk3
  ];
  runtimeLibraryPath = lib.makeLibraryPath runtimeDependencies;
  validCpuTypes = builtins.attrNames lib.systems.parse.cpuTypes;
  providedCpuTypes = builtins.filter (arch: builtins.elem arch validCpuTypes) (
    builtins.attrNames sourcePerArch
  );
  result = stdenv.mkDerivation {
    pname =
      if sourcePerArch.packageType == "jdk" then
        "${name-prefix}-bin"
      else
        "${name-prefix}-${sourcePerArch.packageType}-bin";

    version = sourcePerArch.${cpuName}.version or (throw "unsupported CPU ${cpuName}");

    src = fetchurl {
      inherit (sourcePerArch.${cpuName}) url sha256;
    };

    nativeBuildInputs = [
      autoPatchelfHook
      makeWrapper
    ];

    buildInputs = [
      alsa-lib # libasound.so wanted by lib/libjsound.so
      fontconfig
      freetype
      (lib.getLib stdenv.cc.cc) # libstdc++.so.6
      libx11
      libxext
      libxi
      libxrender
      libxtst
      zlib
    ]
    ++ lib.optional stdenv.hostPlatform.isAarch32 libffi;

    installPhase = ''
      cd ..

      mv $sourceRoot $out

      # jni.h expects jni_md.h to be in the header search path.
      ln -s $out/include/linux/*_md.h $out/include/

      # Remove some broken manpages.
      # Only for 11 and earlier.
      [ -e "$out/man/ja" ] && rm -r $out/man/ja*

      # Remove embedded freetype to avoid problems like
      # https://github.com/NixOS/nixpkgs/issues/57733
      find "$out" -name 'libfreetype.so*' -delete

      # Propagate the setJavaClassPath setup hook from the JDK so that
      # any package that depends on the JDK has $CLASSPATH set up
      # properly.
      mkdir -p $out/nix-support
      printWords ${setJavaClassPath} > $out/nix-support/propagated-build-inputs

      # Set JAVA_HOME automatically.
      cat <<EOF >> "$out/nix-support/setup-hook"
      if [ -z "\''${JAVA_HOME-}" ]; then export JAVA_HOME=$out; fi
      EOF

      # We cannot use -exec since wrapProgram is a function but not a command.
      #
      # jspawnhelper is executed from JVM, so it doesn't need to wrap it, and it
      # breaks building OpenJDK (#114495).
      for bin in $( find "$out" -executable -type f -not -name jspawnhelper ); do
        if patchelf --print-interpreter "$bin" &> /dev/null; then
          wrapProgram "$bin" --prefix LD_LIBRARY_PATH : "${runtimeLibraryPath}"
        fi
      done
    '';

    preFixup = ''
      find "$out" -name libfontmanager.so -exec \
        patchelf --add-needed libfontconfig.so {} \;
    '';

    # See: https://github.com/NixOS/patchelf/issues/10
    dontStrip = 1;

    # FIXME: use multiple outputs or return actual JRE package
    passthru = {
      home = result;
      jre = result;
    };

    meta = {
      inherit knownVulnerabilities;
      description = "${brand-name}, prebuilt OpenJDK binary";

      license = with lib.licenses; [
        gpl2
        classpathException20
      ];

      sourceProvenance = with lib.sourceTypes; [
        binaryNativeCode
        binaryBytecode
      ];

      maintainers = with lib.maintainers; [ taku0 ];
      platforms = map (arch: arch + "-linux") providedCpuTypes; # some inherit jre.meta.platforms
      mainProgram = "java";
      teams = [ lib.teams.java ];
    };
  };
in
result
