{
  lib,
  stdenv,
  fetchFromGitHub,
  SDL_image,
  SDL_mixer,
  SDL_sound,
  SDL_ttf,
  cmake,
  darwin,
  dosbox,
  libGLU,
  libiconv,
  libx11,
  mesa,
  pkg-config,
  pkg-config-unwrapped,
  sdl2-compat,
  testers,
  # Boolean flags
  libGLSupported ? lib.elem stdenv.hostPlatform.system mesa.meta.platforms,
  openglSupport ? libGLSupported,
}:

let
  inherit (darwin) autoSignDarwinBinariesHook;
in
stdenv.mkDerivation (finalAttrs: {
  pname = "sdl12-compat";
  version = "1.2.76";

  src = fetchFromGitHub {
    owner = "libsdl-org";
    repo = "sdl12-compat";
    rev = "release-" + finalAttrs.version;
    hash = "sha256-hSHtYFn4gr8Y9cNyLBT6frDgidNCRENPtTrtGfgH3po=";
  };

  patches = [
    # The setup hook scans paths of buildInputs to find SDL related packages and
    # adds their include and library paths to environment variables. The sdl-config
    # is patched to use these variables to produce correct flags for compiler.
    ./find-headers.patch
  ];

  strictDeps = true;

  nativeBuildInputs = [
    cmake
    pkg-config
  ]
  ++ lib.optionals (stdenv.hostPlatform.isDarwin && stdenv.hostPlatform.isAarch64) [
    autoSignDarwinBinariesHook
  ];

  buildInputs = [
    libx11
    sdl2-compat
  ]
  ++ lib.optionals stdenv.hostPlatform.isDarwin [
    libiconv
  ]
  ++ lib.optionals openglSupport [ libGLU ];

  cmakeFlags =
    let
      rpath = lib.makeLibraryPath [ sdl2-compat ];
    in
    [
      (lib.cmakeFeature "CMAKE_INSTALL_RPATH" rpath)
      (lib.cmakeFeature "CMAKE_BUILD_RPATH" rpath)
      (lib.cmakeBool "SDL12TESTS" finalAttrs.finalPackage.doCheck)
    ];

  # Darwin fails with "Critical error: required built-in appearance SystemAppearance not found"
  doCheck = !stdenv.hostPlatform.isDarwin;

  checkPhase = ''
    runHook preCheck
    ./test/testver
    runHook postCheck
  '';

  postInstall = ''
    # allow as a drop in replacement for SDL
    # Can be removed after treewide switch from pkg-config to pkgconf
    ln -s $out/lib/pkgconfig/sdl12_compat.pc $out/lib/pkgconfig/sdl.pc
  '';

  __structuredAttrs = true;
  dontPatchELF = true; # don't strip rpath
  enableParallelBuilding = true;
  # re-export PKG_CHECK_MODULES m4 macro used by sdl.m4
  propagatedNativeBuildInputs = [ pkg-config-unwrapped ];
  setupHook = ./setup-hook.sh;

  passthru.tests = {
    inherit
      SDL_image
      SDL_ttf
      SDL_mixer
      SDL_sound
      dosbox
      ;

    pkg-config = testers.testMetaPkgConfig finalAttrs.finalPackage;
  };

  meta = {
    description = "Cross-platform multimedia library - build SDL 1.2 applications against 2.0";
    homepage = "https://www.libsdl.org/";
    license = lib.licenses.zlib;
    maintainers = with lib.maintainers; [ peterhoeg ];
    platforms = lib.platforms.all;
    mainProgram = "sdl-config";

    pkgConfigModules = [
      "sdl"
      "sdl12_compat"
    ];

    teams = [ lib.teams.sdl ];
  };
})
