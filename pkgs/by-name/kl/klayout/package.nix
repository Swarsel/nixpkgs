{
  lib,
  stdenv,
  fetchFromGitHub,
  curl,
  expat,
  installShellFiles,
  libgit2,
  libpng,
  nix-update-script,
  perl,
  python3,
  python3Packages,
  qt6,
  ruby,
  which,
  zlib,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "klayout";
  version = "0.30.8";

  src = fetchFromGitHub {
    owner = "KLayout";
    repo = "klayout";
    tag = "v${finalAttrs.version}";
    hash = "sha256-RjMH6hrc0jyCLgG1D6cztBp5Fb3W5HgTxVTfI2bxgCs=";
  };

  postPatch = ''
    patchShebangs --build .
  '';

  strictDeps = true;

  nativeBuildInputs = [
    (python3.withPackages (ps: [ ps.tomli ]))
    installShellFiles
    perl
    ruby
    which
    qt6.wrapQtAppsHook
    qt6.qmake
    qt6.qtbase
    qt6.qtmultimedia
    qt6.qtsvg
    qt6.qttools
    qt6.qt5compat
  ];

  buildInputs = [
    qt6.qtbase
    qt6.qtmultimedia
    qt6.qtsvg
    qt6.qttools
    qt6.qt5compat
    libgit2
    libpng
    expat
    curl
    zlib
  ];

  env = {
    NIX_CFLAGS_COMPILE = toString [ "-Wno-parentheses" ];
    NIX_LDFLAGS = lib.optionalString stdenv.hostPlatform.isDarwin "-headerpad_max_install_names";
  };

  buildPhase = ''
    runHook preBuild
    mkdir -p $out/lib

    ./build.sh \
      -prefix $out/lib \
      -option "-j$NIX_BUILD_CORES" \
      -rpath $out/lib \
      -libpng \
      -libcurl \
      -libexpat

    runHook postBuild
  '';

  postBuild =
    lib.optionalString stdenv.hostPlatform.isLinux ''
      install -Dm444 etc/klayout.desktop -t $out/share/applications
      install -Dm444 etc/logo.png $out/share/icons/hicolor/256x256/apps/klayout.png

      installBin $out/lib/klayout
    ''
    + lib.optionalString stdenv.hostPlatform.isDarwin ''
      mkdir -p $out/Applications
      mv $out/lib/klayout.app $out/Applications/
    '';

  preFixup = lib.optionalString stdenv.hostPlatform.isDarwin ''
    exec_name=$out/Applications/klayout.app/Contents/MacOS/klayout

    for lib in $out/lib/libklayout_*.0.dylib; do
      base_name=$(basename $lib)
      install_name_tool -change "$base_name" "@rpath/$base_name" "$exec_name"
    done

    wrapQtApp "$out/Applications/klayout.app/Contents/MacOS/klayout"
  '';

  # Installation is handled manually in buildPhase/postBuild via build.sh -prefix
  dontInstall = true;
  dontUseQmakeConfigure = true;
  dontWrapQtApps = stdenv.hostPlatform.isDarwin;
  # Fix for: "gsiDeclQMessageLogger.cc: error: format not a string literal"
  hardeningDisable = [ "format" ];

  passthru = {
    tests = {
      pythonPackage = python3Packages.klayout;
    };

    updateScript = nix-update-script { };
  };

  meta = {
    description = "High performance layout viewer and editor with support for GDS and OASIS";
    homepage = "https://www.klayout.de/";
    changelog = "https://www.klayout.de/development.html#${finalAttrs.version}";
    license = with lib.licenses; [ gpl2Plus ];
    maintainers = [ ];
    platforms = lib.platforms.linux ++ lib.platforms.darwin;
    mainProgram = "klayout";
  };
})
