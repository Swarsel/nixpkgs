{
  lib,
  stdenv,
  fetchzip,
  gtk3,
  jdk,
  libGLU,
  pkg-config,
  stripJavaArchivesHook,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "swt";
  # NOTE: In case you wish to override, don't override version, override
  # `fullVersion`.
  version = builtins.elemAt (lib.splitString "-" finalAttrs.fullVersion) 1;

  # Alas, the Eclipse Project apparently doesn't produce source-only
  # releases of SWT.  So we just grab a binary release and extract
  # "src.zip" from that.
  src =
    let
      inherit (finalAttrs.passthru) srcMetadata;
    in
    assert srcMetadata != null;
    fetchzip {
      inherit (srcMetadata) hash;
      url = "https://download.eclipse.org/eclipse/downloads/drops4/${finalAttrs.fullVersion}/swt-${finalAttrs.version}-${srcMetadata.platform}.zip";

      postFetch =
        # On Linux, extract and use only the sources from src.zip
        lib.optionalString stdenv.hostPlatform.isLinux ''
          mkdir "$unpackDir"
          cd "$unpackDir"

          renamed="$TMPDIR/src.zip"
          mv -- "$out/src.zip" "$renamed"
          unpackFile "$renamed"
          rm -r -- "$out"

          mv -- "$unpackDir" "$out"
        '';

      stripRoot = false;
    };

  postPatch = lib.optionalString stdenv.hostPlatform.isLinux "substituteInPlace library/make_linux.mak --replace-fail 'CFLAGS += -Werror' ''";

  nativeBuildInputs = [
    jdk
    stripJavaArchivesHook
  ]
  ++ lib.optionals stdenv.hostPlatform.isLinux [
    pkg-config
  ];

  buildInputs = lib.optionals stdenv.hostPlatform.isLinux [
    gtk3
    libGLU
  ];

  # GTK4 is not supported yet. See:
  # https://github.com/eclipse-platform/eclipse.platform.swt/issues/652
  makeFlags = lib.optionals stdenv.hostPlatform.isLinux [ "gtk3" ];

  env = {
    AWT_LIB_PATH = "${jdk}/lib/openjdk/lib";
    # Used by the makefile which is responsible for the shared objects only
    OUTPUT_DIR = "${placeholder "out"}/lib";
    SWT_JAVA_HOME = jdk;
  }
  // lib.optionalAttrs stdenv.hostPlatform.isLinux {
    NIX_CFLAGS_COMPILE = "-std=gnu17";
  };

  preBuild = lib.optionalString stdenv.hostPlatform.isLinux ''
    cd library
    mkdir -p $OUTPUT_DIR
  '';

  # Build the jar (Linux only, Darwin uses prebuilt)
  postBuild = lib.optionalString stdenv.hostPlatform.isLinux ''
    cd ../
    mkdir out
    find org/ -name '*.java' -type f -exec javac -encoding utf8 -d out/ {} +
    # Copy non Java resource files
    find org/ -not -name '*.java' -not -name '*.html' -type f -exec cp {} out/{} \;
  '';

  # The makefile doesn't have an install target, the installation of the shared
  # objects is part of the `all` target.
  installPhase = ''
    runHook preInstall

    install -d -- "$out/jars"

  ''
  # On Darwin, use the prebuilt swt.jar which includes native libraries
  + lib.optionalString stdenv.hostPlatform.isDarwin ''
    # Remove signature files to avoid validation errors after stripJavaArchivesHook modifies the jar
    mkdir -p jar-temp
    cd jar-temp
    ${jdk}/bin/jar -xf ../swt.jar
    rm -f META-INF/*.SF META-INF/*.RSA META-INF/*.DSA
    ${jdk}/bin/jar -cf "$out/jars/swt.jar" *
    cd ..
    rm -rf jar-temp

  ''
  # On Linux, build from source
  + lib.optionalString stdenv.hostPlatform.isLinux ''
    install -m 644 -t out -- version.txt
    (cd out && jar -c *) > "$out/jars/swt.jar"

  ''
  + ''
    runHook postInstall
  '';

  fullVersion = "R-4.34-202411201800";
  hardeningDisable = [ "format" ];

  passthru.srcMetadata =
    finalAttrs.passthru.srcMetadataByPlatform.${stdenv.hostPlatform.system} or null;

  passthru.srcMetadataByPlatform = {
    aarch64-darwin.hash = "sha256-jvxmoRFGquYClPgMqWi2ylw26YiGSG5bONnM1PcjlTM=";
    aarch64-darwin.platform = "cocoa-macosx-aarch64";
    aarch64-linux.hash = "sha256-lKAB2aCI3dZdt3pE7uSvSfxc8vc3oMSTCx5R+71Aqdk=";
    aarch64-linux.platform = "gtk-linux-aarch64";
    ppc64le-linux.hash = "sha256-lKAB2aCI3dZdt3pE7uSvSfxc8vc3oMSTCx5R+71Aqdk=";
    ppc64le-linux.platform = "gtk-linux-ppc64le";
    riscv64-linux.hash = "sha256-lKAB2aCI3dZdt3pE7uSvSfxc8vc3oMSTCx5R+71Aqdk=";
    riscv64-linux.platform = "gtk-linux-riscv64";
    x86_64-linux.hash = "sha256-lKAB2aCI3dZdt3pE7uSvSfxc8vc3oMSTCx5R+71Aqdk=";
    # Note: This may look like an error but the content of the src.zip is in fact
    # equal on all linux systems as well as all darwin systems. Even though each
    # of these zip archives themselves contains a different hash.
    x86_64-linux.platform = "gtk-linux-x86_64";
  };

  meta = {
    description = ''
      A widget toolkit for Java to access the user-interface facilities of
      the operating systems on which it is implemented.
    '';

    homepage = "https://www.eclipse.org/swt/";

    license = with lib.licenses; [
      # All of these are located in the about_files directory of the source
      ijg
      lgpl21
      mpl11
      mpl20
    ];

    # The darwin src zip file holds simply a prebuilt swt.jar file
    sourceProvenance = lib.optionals stdenv.hostPlatform.isDarwin [
      lib.sourceTypes.binaryNativeCode
    ];

    maintainers = with lib.maintainers; [ mio ];
    platforms = lib.attrNames finalAttrs.passthru.srcMetadataByPlatform;
    # Fails with: `java.nio.file.NoSuchFileException: ../swt.jar`
    broken = stdenv.hostPlatform.isDarwin && stdenv.hostPlatform.isx86_64;
  };
})
