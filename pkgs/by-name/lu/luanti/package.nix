{
  lib,
  stdenv,
  fetchFromGitHub,
  SDL2,
  bzip2,
  cmake,
  coreutils,
  curl,
  doxygen,
  freetype,
  gettext,
  gmp,
  graphviz,
  hiredis,
  jsoncpp,
  leveldb,
  libGLU,
  libiconv,
  libjpeg,
  libogg,
  libpng,
  libpq,
  libspatialindex,
  libvorbis,
  libx11,
  libxi,
  luajit,
  ncurses,
  ninja,
  nix-update-script,
  openal,
  prometheus-cpp,
  sdl3,
  sqlite,
  substitute,
  buildClient ? true,
  buildServer ? true,
  # Use SDL3 (experimental) instead of SDL2
  useSdl3 ? false,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "luanti";
  version = "5.16.1";

  src = fetchFromGitHub {
    owner = "luanti-org";
    repo = "luanti";
    tag = finalAttrs.version;
    hash = "sha256-EzLjLkN/3BdcpWJ92QnrdhxKmY6Bz2JkOC0oX0TrUtI=";
  };

  patches = [
    (substitute {
      src = ./0000-mark-rm-for-substitution.patch;

      substitutions = [
        "--subst-var-by"
        "RM_COMMAND"
        "${coreutils}/bin/rm"
      ];
    })
  ];

  postPatch = lib.optionalString stdenv.hostPlatform.isDarwin ''
    sed -i '/pagezero_size/d;/fixup_bundle/d' src/CMakeLists.txt
  '';

  nativeBuildInputs = [
    cmake
    doxygen
    graphviz
    ninja
  ];

  buildInputs = [
    jsoncpp
    gettext
    freetype
    sqlite
    curl
    bzip2
    ncurses
    gmp
    libspatialindex
  ]
  ++ lib.optional (lib.meta.availableOn stdenv.hostPlatform luajit) luajit
  ++ lib.optionals stdenv.hostPlatform.isDarwin [
    libiconv
  ]
  ++ lib.optionals buildClient [
    libpng
    libjpeg
    libGLU
    openal
    libogg
    libvorbis
    (if useSdl3 then sdl3 else SDL2)
  ]
  ++ lib.optionals (buildClient && !stdenv.hostPlatform.isDarwin) [
    libx11
    libxi
  ]
  ++ lib.optionals buildServer [
    leveldb
    libpq
    hiredis
    prometheus-cpp
  ];

  cmakeFlags = [
    (lib.cmakeBool "BUILD_CLIENT" buildClient)
    (lib.cmakeBool "BUILD_SERVER" buildServer)
    (lib.cmakeBool "BUILD_UNITTESTS" (finalAttrs.finalPackage.doCheck or false))
    (lib.cmakeBool "ENABLE_PROMETHEUS" buildServer)
    (lib.cmakeBool "USE_SDL3" useSdl3)
    # Ensure we use system libraries
    (lib.cmakeBool "ENABLE_SYSTEM_GMP" true)
    (lib.cmakeBool "ENABLE_SYSTEM_JSONCPP" true)
    # Updates are handled by nix anyway
    (lib.cmakeBool "ENABLE_UPDATE_CHECKER" false)
    # ...but make it clear that this is a nix package
    (lib.cmakeFeature "VERSION_EXTRA" "NixOS")
  ];

  doCheck = true;

  postInstall =
    lib.optionalString stdenv.hostPlatform.isLinux ''
      patchShebangs $out
    ''
    + lib.optionalString stdenv.hostPlatform.isDarwin ''
      mkdir -p $out/Applications
      mv $out/luanti.app $out/Applications
    '';

  passthru.updateScript = nix-update-script { };

  meta = {
    description = "Open source voxel game engine (formerly Minetest)";
    homepage = "https://www.luanti.org/";
    license = lib.licenses.lgpl21Plus;

    maintainers = with lib.maintainers; [
      fpletz
      fgaz
      jk
    ];

    platforms = lib.platforms.linux ++ lib.platforms.darwin;
    mainProgram = if buildClient then "luanti" else "luantiserver";
  };
})
