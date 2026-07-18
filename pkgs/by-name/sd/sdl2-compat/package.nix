{
  lib,
  stdenv,
  fetchFromGitHub,
  SDL2_gfx,
  SDL2_image,
  SDL2_mixer,
  SDL2_net,
  SDL2_sound,
  # passthru tests
  SDL2_ttf,
  cmake,
  ffmpeg,
  libGL,
  libx11,
  ninja,
  nix-update-script,
  qemu,
  sdl12-compat,
  sdl3,
  testers,
  x11Support ? !stdenv.hostPlatform.isAndroid && !stdenv.hostPlatform.isWindows,
}:
let
  # tray support on sdl3 pulls in gtk3, which is quite an expensive dependency.
  # sdl2 does not support the tray, so we can just disable that requirement.
  sdl3' = sdl3.override { traySupport = false; };
in
stdenv.mkDerivation (finalAttrs: {
  pname = "sdl2-compat";
  version = "2.32.70";

  src = fetchFromGitHub {
    owner = "libsdl-org";
    repo = "sdl2-compat";
    tag = "release-${finalAttrs.version}";
    hash = "sha256-IKfcF03I+kCewjdEcw7ANd6sCZvjNksIhBfJan9SSUY=";
  };

  outputs = [
    "out"
    "dev"
  ];

  patches = [
    ./find-headers.patch
  ];

  nativeBuildInputs = [
    cmake
    ninja
  ];

  buildInputs = [
    sdl3'
  ]
  ++ lib.optional x11Support libx11;

  cmakeFlags = [
    (lib.cmakeBool "SDL2COMPAT_TESTS" finalAttrs.finalPackage.doCheck)
    (lib.cmakeFeature "CMAKE_INSTALL_RPATH" (lib.makeLibraryPath [ sdl3' ]))
    (lib.cmakeFeature "CMAKE_BUILD_RPATH" (lib.makeLibraryPath [ sdl3' ]))
  ];

  # skip timing-based tests as those are flaky
  env.SDL_TESTS_QUICK = 1;
  doCheck = true;
  checkInputs = [ libGL ];

  postFixup = ''
    # allow as a drop in replacement for SDL2
    # Can be removed after treewide switch from pkg-config to pkgconf
    ln -s $dev/lib/pkgconfig/sdl2-compat.pc $dev/lib/pkgconfig/sdl2.pc
  '';

  # SDL3 is dlopened at runtime, leave it in runpath
  dontPatchELF = true;
  outputBin = "dev";
  setupHook = ./setup-hook.sh;

  passthru = {
    tests = {
      inherit
        sdl12-compat
        SDL2_ttf
        SDL2_net
        SDL2_gfx
        SDL2_sound
        SDL2_mixer
        SDL2_image
        ffmpeg
        ;

      pkg-config = testers.testMetaPkgConfig finalAttrs.finalPackage;
    }
    // lib.optionalAttrs stdenv.hostPlatform.isLinux {
      inherit qemu;
    };

    updateScript = nix-update-script {
      extraArgs = [
        "--version-regex"
        "release-(.*)"
      ];
    };
  };

  meta = {
    description = "SDL2 compatibility layer that uses SDL3 behind the scenes";
    homepage = "https://libsdl.org";
    changelog = "https://github.com/libsdl-org/sdl2-compat/releases/tag/${finalAttrs.src.tag}";
    license = lib.licenses.zlib;

    maintainers = with lib.maintainers; [
      nadiaholmquist
    ];

    platforms = lib.platforms.all;

    pkgConfigModules = [
      "sdl2-compat"
      "sdl2"
    ];

    teams = [ lib.teams.sdl ];
  };
})
