{
  lib,
  stdenv,
  fetchFromGitHub,
  # to download assets
  aria2,
  buildFHSEnv,
  cacert,
  cmake,
  copyDesktopItems,
  curl,
  fetchzip,
  freetype,
  gcc,
  geoip,
  glew,
  gmp,
  libGL,
  libjpeg,
  libogg,
  libopus,
  libpng,
  libvorbis,
  libwebp,
  libx11,
  lua5,
  makeDesktopItem,
  ncurses,
  nettle,
  openal,
  opusfile,
  sdl3,
  zlib,
}:

let
  version = "0.56.2";
  binary-deps-version = "11";

  src = fetchFromGitHub {
    owner = "Unvanquished";
    repo = "Unvanquished";
    tag = "v${version}";
    hash = "sha256-+3y9UJAMfMDIO4feHTyb5IWIelRSsH6KF6WAtx7rric=";
    fetchSubmodules = true;
  };

  unvanquished-binary-deps = stdenv.mkDerivation rec {
    # DISCLAIMER: this is selected binary crap from the NaCl SDK
    pname = "unvanquished-binary-deps";
    version = binary-deps-version;

    src = fetchzip {
      url = "https://dl.unvanquished.net/deps/linux-amd64-default_${version}.tar.xz";
      hash = "sha256-1PPqQYnMBFR7Jr48qiqQEduEjiFWx3XyvfPBwX/PzIY=";
    };

    preCheck = ''
      # check it links correctly
      pnacl/bin/clang -v
    '';

    installPhase = ''
      runHook preInstall

      mkdir -p $out
      cp -R ./* $out/

      runHook postInstall
    '';

    preFixup = ''
      # We are not using the autoPatchelfHook, because it would make
      # nacl_bootstrap_helper unable to load nacl_loader:
      # "nacl_loader: ELF file has unreasonable e_phnum=13"
      interpreter="$(< "$NIX_CC/nix-support/dynamic-linker")"
      for f in pnacl/bin/*; do
        if [ -f "$f" && -x "$f" ]; then
          echo "Patching $f"
          patchelf --set-interpreter "$interpreter" "$f"
        fi
      done
    '';

    dontPatchELF = true;
  };

  libstdcpp-preload-for-unvanquished-nacl = stdenv.mkDerivation {
    propagatedBuildInputs = [ gcc.cc.lib ];

    buildCommand = ''
      mkdir $out/etc -p
      echo ${gcc.cc.lib}/lib/libstdc++.so.6 > $out/etc/ld-nix.so.preload
    '';

    name = "libstdcpp-preload-for-unvanquished-nacl";
  };

  fhsEnv = buildFHSEnv {
    inherit version;
    pname = "unvanquished-fhs-wrapper";
    targetPkgs = pkgs: [ libstdcpp-preload-for-unvanquished-nacl ];
  };

  wrapBinary = binary: wrappername: ''
    cat > $out/lib/${binary}-wrapper <<-EOT
    #!/bin/sh
    exec $out/lib/${binary} -pakpath ${unvanquished-assets} "\$@"
    EOT
    chmod +x $out/lib/${binary}-wrapper

    cat > $out/bin/${wrappername} <<-EOT
    #!/bin/sh
    exec ${fhsEnv}/bin/unvanquished-fhs-wrapper $out/lib/${binary}-wrapper "\$@"
    EOT
    chmod +x $out/bin/${wrappername}
  '';

  unvanquished-assets = stdenv.mkDerivation {
    inherit version src;
    pname = "unvanquished-assets";

    nativeBuildInputs = [
      aria2
      cacert
    ];

    buildCommand = ''
      bash $src/download-paks --cache=$(pwd) --version=${version} $out
    '';

    outputHash = "sha256-lXhzrA30wiNtCvpl4xxrIyl5Vcd4TvSQAuBK73vZXHs=";
    outputHashMode = "recursive";
  };

  # this really is the daemon game engine, the game itself is in the assets
in
stdenv.mkDerivation rec {
  inherit version src binary-deps-version;
  pname = "unvanquished";

  nativeBuildInputs = [
    cmake
    copyDesktopItems
  ];

  buildInputs = [
    gmp
    libGL
    zlib
    ncurses
    geoip
    lua5
    nettle
    curl
    sdl3
    freetype
    glew
    openal
    libopus
    opusfile
    libogg
    libvorbis
    libjpeg
    libwebp
    libx11
    libpng
  ];

  cmakeFlags = [
    "-DBUILD_CGAME=FALSE"
    "-DBUILD_SGAME=FALSE"
    "-DUSE_HARDENING=TRUE"
    "-DUSE_LTO=TRUE"
    "-DUSE_OPENMP=TRUE"
    "-DUSE_EXTERNAL_DEPS_LIBS=FALSE"
    "-DOpenGL_GL_PREFERENCE=LEGACY" # https://github.com/DaemonEngine/Daemon/issues/474
  ];

  preConfigure = ''
    TARGET="linux-amd64-default_${binary-deps-version}"
    mkdir daemon/external_deps/"$TARGET"
    cp -r ${unvanquished-binary-deps}/* daemon/external_deps/"$TARGET"/
    chmod +w -R daemon/external_deps/"$TARGET"/
  '';

  installPhase = ''
    runHook preInstall

    for f in daemon daemon-tty daemonded nacl_loader nacl_helper_bootstrap; do
      install -Dm0755 -t $out/lib/ $f
    done
    install -Dm0644 -t $out/lib/ irt_core-amd64.nexe

    mkdir $out/bin/
    ${wrapBinary "daemon" "unvanquished"}
    ${wrapBinary "daemon-tty" "unvanquished-tty"}
    ${wrapBinary "daemonded" "unvanquished-server"}

    for d in ${src}/dist/icons/*; do
      install -Dm0644 -t $out/share/icons/hicolor/$(basename $d)/apps/ $d/unvanquished.png
    done

    runHook postInstall
  '';

  desktopItems = [
    (makeDesktopItem {
      categories = [
        "Game"
        "ActionGame"
        "StrategyGame"
      ];

      comment = "FPS/RTS Game - Aliens vs. Humans";
      desktopName = "Unvanquished";
      exec = "unvanquished";
      icon = "unvanquished";
      name = "net.unvanquished.Unvanquished.desktop";
      prefersNonDefaultGPU = true;
    })
    (makeDesktopItem {
      desktopName = "Unvanquished (protocol handler)";
      exec = "unvanquished -connect %u";
      mimeTypes = [ "x-scheme-handler/unv" ];
      name = "net.unvanquished.UnvanquishedProtocolHandler.desktop";
      noDisplay = true;
      prefersNonDefaultGPU = true;
    })
  ];

  meta = {
    description = "Fast paced, first person strategy game";
    homepage = "https://unvanquished.net/";

    # don't replace the following lib.licenses.zlib with just "zlib",
    # or you would end up with the package instead
    license = with lib.licenses; [
      mit
      gpl3Plus
      lib.licenses.zlib
      bsd3 # engine
      cc-by-sa-25
      cc-by-sa-30
      cc-by-30
      cc-by-sa-40
      cc0 # assets
    ];

    sourceProvenance = with lib.sourceTypes; [
      fromSource
      binaryNativeCode # unvanquished-binary-deps
    ];

    maintainers = with lib.maintainers; [ afontain ];
    platforms = [ "x86_64-linux" ];
    downloadPage = "https://unvanquished.net/download/";
  };
}
