{
  lib,
  stdenv,
  SDL2,
  callPackage,
  cmake,
  espeak-ng,
  ffmpeg,
  file,
  freetype,
  glib,
  gumbo,
  harfbuzz,
  jbig2dec,
  leptonica,
  libGL,
  libdrm,
  libffi,
  libgbm,
  libjpeg,
  libusb1,
  libuvc,
  libvlc,
  libvncserver,
  libx11,
  libxau,
  libxcb,
  libxcb-util,
  libxcb-wm,
  libxcomposite,
  libxdmcp,
  libxfixes,
  libxkbcommon,
  luajit,
  makeWrapper,
  mupdf,
  openal,
  openjpeg,
  pcre2,
  pkg-config,
  ruby,
  sqlite,
  tesseract,
  valgrind,
  wayland,
  wayland-protocols,
  wayland-scanner,
  xz,
  # Boolean flags
  buildManPages ? true,
  # Configurable options
  sources ? callPackage ./sources.nix { },
  useBuiltinLua ? false,
  useEspeak ? !stdenv.hostPlatform.isDarwin,
  useStaticLibuvc ? true,
  useStaticOpenAL ? true,
  useStaticSqlite ? true,
  # For debugging only, disabled by upstream
  useTracy ? false,
}:

stdenv.mkDerivation (finalAttrs: {
  inherit (sources.letoram-arcan) pname version src;

  outputs = [
    "out"
    "dev"
    "lib"
    "man"
  ];

  postPatch = ''
    substituteInPlace ./src/platform/posix/paths.c \
      --replace-fail "/usr/bin" "$out/bin" \
      --replace-fail "/usr/share" "$out/share"
    substituteInPlace ./src/CMakeLists.txt \
      --replace-fail "SETUID" "# SETUID"
  '';

  strictDeps = true;

  nativeBuildInputs = [
    cmake
    makeWrapper
    pkg-config
    wayland-scanner
  ]
  ++ lib.optionals buildManPages [ ruby ];

  buildInputs = [
    SDL2
    ffmpeg
    file
    freetype
    glib
    gumbo
    harfbuzz
    jbig2dec
    leptonica
    libGL
    libx11
    libxau
    libxcomposite
    libxdmcp
    libxfixes
    libdrm
    libffi
    libjpeg
    libusb1
    libuvc
    libvlc
    libvncserver
    libxcb
    libxkbcommon
    libgbm
    mupdf
    openal
    openjpeg
    pcre2
    sqlite
    tesseract
    valgrind
    wayland
    wayland-protocols
    libxcb-util
    libxcb-wm
    xz
  ]
  ++ lib.optionals (!useBuiltinLua) [ luajit ]
  ++ lib.optionals useEspeak [ espeak-ng ];

  cmakeFlags = [
    # The upstream project recommends tagging the distribution
    (lib.cmakeFeature "DISTR_TAG" "Nixpkgs")
    (lib.cmakeFeature "ENGINE_BUILDTAG" finalAttrs.src.rev)
    (lib.cmakeFeature "BUILD_PRESET" "everything")
    (lib.cmakeBool "BUILTIN_LUA" useBuiltinLua)
    (lib.cmakeBool "DISABLE_JIT" useBuiltinLua)
    (lib.cmakeBool "STATIC_LIBUVC" useStaticLibuvc)
    (lib.cmakeBool "STATIC_SQLite3" useStaticSqlite)
    (lib.cmakeBool "ENABLE_TRACY" useTracy)
    "../src"
  ];

  # INFO: Arcan build scripts require the manpages to be generated *before* the
  # `configure` phase
  preConfigure = lib.optionalString buildManPages ''
    pushd doc
    ruby docgen.rb mangen
    popd
  '';

  hardeningDisable = [ "format" ];

  # Emulate external/git/clone.sh
  postUnpack =
    let
      inherit (sources)
        letoram-openal
        libuvc
        luajit
        tracy
        ;
      prepareSource =
        flag: source: destination:
        lib.optionalString flag ''
          cp -va ${source}/ ${destination}
          chmod --recursive 744 ${destination}
        '';
    in
    ''
      pushd $sourceRoot/external/git/
    ''
    + prepareSource useStaticOpenAL letoram-openal.src "openal"
    + prepareSource useStaticLibuvc libuvc.src "libuvc"
    + prepareSource useBuiltinLua luajit.src "luajit"
    + prepareSource useTracy tracy.src "tracy"
    + ''
      popd
    '';

  passthru = {
    inherit sources;
    wrapper = callPackage ./wrapper.nix { };
  };

  meta = {
    description = "Combined Display Server, Multimedia Framework, Game Engine";

    longDescription = ''
      Arcan is a portable and fast self-sufficient multimedia engine for
      advanced visualization and analysis work in a wide range of applications
      e.g. game development, real-time streaming video, monitoring and
      surveillance, up to and including desktop compositors and window managers.
    '';

    homepage = "https://arcan-fe.com/";

    license = with lib.licenses; [
      bsd3
      gpl2Plus
      lgpl2Plus
    ];

    maintainers = [ ];
    platforms = lib.platforms.unix;
    teams = with lib.teams; [ ngi ];
  };
})
