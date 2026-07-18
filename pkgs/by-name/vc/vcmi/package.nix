{
  lib,
  stdenv,
  fetchFromGitHub,
  SDL2,
  SDL2_image,
  SDL2_mixer,
  SDL2_ttf,
  boost,
  cmake,
  ffmpeg,
  fuzzylite,
  gettext,
  innoextract,
  libsquish,
  luajit,
  minizip,
  ninja,
  onetbb,
  onnxruntime,
  pkg-config,
  python3,
  qt6,
  unshield,
  versionCheckHook,
  xz,
  zlib,
  enableMMAI ? true,
}:
stdenv.mkDerivation (finalAttrs: {
  pname = "vcmi";
  version = "1.7.4";

  src = fetchFromGitHub {
    owner = "vcmi";
    repo = "vcmi";
    tag = finalAttrs.version;
    hash = "sha256-iV1twkoOJyUsUkq17mdTYk1YvfmUtLHdtR3H77BoNJk=";
    fetchSubmodules = true;

    # Disable git background maintenance for the whole prefetch, including submodule clones.
    # Upstream nix-prefetch-git only disables it on the outer repo (NixOS/nixpkgs#524215), so
    # submodule clones can still race with their own maintenance and break `.git` cleanup.
    preFetch = ''
      export GIT_CONFIG_GLOBAL="$TMPDIR/gitconfig"
      printf '[maintenance]\n\tauto = false\n' > "$GIT_CONFIG_GLOBAL"
    '';
  };

  strictDeps = true;

  nativeBuildInputs = [
    cmake
    gettext # msgfmt
    ninja
    pkg-config
    python3
    qt6.wrapQtAppsHook
  ];

  buildInputs = [
    SDL2
    SDL2_image
    SDL2_mixer
    SDL2_ttf
    boost
    ffmpeg
    fuzzylite
    libsquish
    luajit
    minizip
    onetbb
    onnxruntime
    qt6.qtbase
    qt6.qttools
    xz
    zlib
  ]
  ++ lib.optional enableMMAI onnxruntime;

  cmakeFlags = [
    (lib.cmakeBool "ENABLE_CLIENT" true)
    (lib.cmakeBool "ENABLE_LUA" true)
    (lib.cmakeBool "ENABLE_ERM" true)
    (lib.cmakeBool "ENABLE_GOLDMASTER" true)
    (lib.cmakeBool "ENABLE_TEST" false) # Requires nonfree data files.
    (lib.cmakeBool "ENABLE_PCH" false)
    (lib.cmakeBool "ENABLE_DISCORD" false)
    (lib.cmakeBool "ENABLE_MMAI" enableMMAI)
    (lib.cmakeFeature "CMAKE_INSTALL_RPATH" "$out/lib/vcmi")
    (lib.cmakeFeature "CMAKE_INSTALL_BINDIR" "bin")
    (lib.cmakeFeature "CMAKE_INSTALL_LIBDIR" "lib")
    (lib.cmakeFeature "CMAKE_INSTALL_DATAROOTDIR" "share")
  ];

  # GCC 15 ICE in -Wmismatched-tags diagnostic during template specialisation lookup
  env.NIX_CFLAGS_COMPILE = lib.optionalString stdenv.cc.isGNU "-Wno-mismatched-tags";
  doInstallCheck = true;
  nativeInstallCheckInputs = [ versionCheckHook ];

  postFixup = ''
    wrapProgram $out/bin/vcmibuilder \
      --prefix PATH : "${
        lib.makeBinPath [
          innoextract
          ffmpeg
          unshield
        ]
      }"
  '';

  __structuredAttrs = true;

  preVersionCheck = ''
    cd $(mktemp -d)
    export \
      XDG_CACHE_HOME="$TMPDIR" \
      XDG_CONFIG_HOME="$TMPDIR" \
      XDG_DATA_HOME="$TMPDIR"
  '';

  versionCheckKeepEnvironment = [
    "XDG_CACHE_HOME"
    "XDG_CONFIG_HOME"
    "XDG_DATA_HOME"
  ];

  versionCheckProgram = "${placeholder "out"}/bin/vcmiclient";

  meta = {
    description = "Open-source engine for Heroes of Might and Magic III";

    longDescription = ''
      VCMI is an open-source engine for Heroes of Might and Magic III, offering
      new and extended possibilities. To use VCMI, you need to own the original
      data files.
    '';

    homepage = "https://vcmi.eu";
    changelog = "https://vcmi.eu/ChangeLog";

    license = with lib.licenses; [
      gpl2Plus
      cc-by-sa-40
    ];

    maintainers = [ lib.maintainers.azahi ];
    platforms = lib.platforms.linux;
    mainProgram = "vcmilauncher";
  };
})
