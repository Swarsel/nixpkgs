{
  lib,
  stdenv,
  fetchFromGitHub,
  buildPackages,
  catch2,
  cmake,
  config,
  expat,
  fetchpatch,
  freetype,
  # dependencies
  glib,
  gperf,
  libice,
  libsm,
  libx11,
  libxext,
  libxfixes,
  libxft,
  libxinerama,
  pandoc,
  pango,
  pkg-config,
  python3,
  versionCheckHook,
  wayland,
  wayland-protocols,
  wayland-scanner,
  cairo ? null,
  curl ? null,
  curlSupport ? true,
  # lib.optional features with extra dependencies
  docsSupport ? true,
  doubleBufferSupport ? x11Support,
  extrasSupport ? true,
  ibmSupport ? true, # IBM/Lenovo notebooks
  imlib2 ? null,
  imlib2Support ? x11Support,
  journalSupport ? true,
  libXNVCtrl ? null,
  libpulseaudio ? null,
  libxdamage ? null,
  libxml2 ? null,
  lua ? null,
  luaCairoSupport ? luaSupport && (x11Support || waylandSupport),
  luaImlib2Support ? luaSupport && imlib2Support,
  luaSupport ? true,
  # lib.optional features without extra dependencies
  mpdSupport ? true,
  ncurses ? null,
  ncursesSupport ? true,
  nvidiaSupport ? false,
  pulseSupport ? config.pulseaudio or false,
  rssSupport ? curlSupport,
  systemd ? null,
  toluapp ? null,
  waylandSupport ? true,
  wirelessSupport ? true,
  wirelesstools ? null,
  x11Support ? true,
  xdamageSupport ? x11Support,
}:

assert docsSupport -> pandoc != null && python3 != null;

assert ncursesSupport -> ncurses != null;

assert xdamageSupport -> x11Support && libxdamage != null;
assert imlib2Support -> x11Support && imlib2 != null;
assert luaSupport -> lua != null;
assert luaImlib2Support -> luaSupport && imlib2Support && toluapp != null;
assert luaCairoSupport -> luaSupport && toluapp != null && cairo != null;
assert luaCairoSupport || luaImlib2Support -> lua.luaversion == "5.4";

assert wirelessSupport -> wirelesstools != null;
assert nvidiaSupport -> libXNVCtrl != null;
assert pulseSupport -> libpulseaudio != null;

assert curlSupport -> curl != null;
assert rssSupport -> curlSupport && libxml2 != null;
assert journalSupport -> systemd != null;

assert extrasSupport -> python3 != null;

stdenv.mkDerivation (finalAttrs: {
  pname = "conky";
  version = "1.22.3";

  src = fetchFromGitHub {
    owner = "brndnmtthws";
    repo = "conky";
    tag = "v${finalAttrs.version}";
    hash = "sha256-WZjYs68/u7XUUriLPW3VMJIFP/HsnraHT6w84usQMYM=";
  };

  # pkg-config doesn't detect wayland-scanner in cross-compilation for some reason
  postPatch = ''
    substituteInPlace cmake/ConkyPlatformChecks.cmake \
      --replace-fail "pkg_get_variable(Wayland_SCANNER wayland-scanner wayland_scanner)" "set(Wayland_SCANNER ${lib.getExe buildPackages.wayland-scanner})"
  '';

  strictDeps = true;

  nativeBuildInputs = [
    cmake
    pkg-config
    gperf
  ]
  ++ lib.optional docsSupport pandoc
  ++ lib.optional (docsSupport || extrasSupport) (
    # Use buildPackages to work around https://github.com/NixOS/nixpkgs/issues/305858
    buildPackages.python3.withPackages (ps: [
      ps.jinja2
      ps.pyyaml
    ])
  )
  ++ lib.optional luaImlib2Support toluapp
  ++ lib.optional luaCairoSupport toluapp;

  buildInputs = [
    glib
    libxinerama
  ]
  ++ lib.optional ncursesSupport ncurses
  ++ lib.optionals x11Support [
    freetype
    libxfixes
    libice
    libx11
    libxext
    libxft
    libxfixes
    libsm
    expat
  ]
  ++ lib.optionals waylandSupport [
    pango
    wayland
    wayland-protocols
  ]
  ++ lib.optional xdamageSupport libxdamage
  ++ lib.optional imlib2Support imlib2
  ++ lib.optional luaSupport lua
  ++ lib.optional luaImlib2Support imlib2
  ++ lib.optional luaCairoSupport cairo
  ++ lib.optional wirelessSupport wirelesstools
  ++ lib.optional curlSupport curl
  ++ lib.optional rssSupport libxml2
  ++ lib.optional nvidiaSupport libXNVCtrl
  ++ lib.optional pulseSupport libpulseaudio
  ++ lib.optional journalSupport systemd;

  cmakeFlags = [
    (lib.cmakeBool "REPRODUCIBLE_BUILD" true)
    (lib.cmakeBool "RELEASE" true)
    (lib.cmakeBool "BUILD_TESTING" finalAttrs.finalPackage.doCheck)
    (lib.cmakeBool "BUILD_EXTRAS" extrasSupport)
    (lib.cmakeBool "BUILD_DOCS" docsSupport)
    (lib.cmakeBool "BUILD_CURL" curlSupport)
    (lib.cmakeBool "BUILD_IBM" ibmSupport)
    (lib.cmakeBool "BUILD_IMLIB2" imlib2Support)
    (lib.cmakeBool "BUILD_LUA_CAIRO" luaCairoSupport)
    (lib.cmakeBool "BUILD_LUA_IMLIB2" luaImlib2Support)
    (lib.cmakeBool "BUILD_MPD" mpdSupport)
    (lib.cmakeBool "BUILD_NCURSES" ncursesSupport)
    (lib.cmakeBool "BUILD_RSS" rssSupport)
    (lib.cmakeBool "BUILD_X11" x11Support)
    (lib.cmakeBool "BUILD_WAYLAND" waylandSupport)
    (lib.cmakeBool "BUILD_XDAMAGE" xdamageSupport)
    (lib.cmakeBool "BUILD_XDBE" doubleBufferSupport)
    (lib.cmakeBool "BUILD_WLAN" wirelessSupport)
    (lib.cmakeBool "BUILD_NVIDIA" nvidiaSupport)
    (lib.cmakeBool "BUILD_PULSEAUDIO" pulseSupport)
    (lib.cmakeBool "BUILD_JOURNAL" journalSupport)
    (lib.cmakeFeature "CMAKE_INSTALL_DATAROOTDIR" "${placeholder "out"}/share")
  ];

  doCheck = true;
  doInstallCheck = true;
  nativeInstallCheckInputs = [ versionCheckHook ];

  meta = {
    description = "Advanced, highly configurable system monitor based on torsmo";
    homepage = "https://conky.cc";
    changelog = "https://github.com/brndnmtthws/conky/releases/tag/${finalAttrs.src.tag}";
    license = lib.licenses.gpl3Plus;
    maintainers = [ lib.maintainers.guibert ];
    platforms = lib.platforms.linux;
    mainProgram = "conky";
  };
})
