{
  lib,
  fetchFromGitHub,
  SDL2,
  cmake,
  gccStdenv,
  gitUpdater,
  glew,
  libjpeg,
  liblockfile,
  libogg,
  libtheora,
  lzo,
  makeWrapper,
  openal,
  pcre,
}:
let
  # Builds with Clang, but hits an assertion failure unless GCC is used
  # https://github.com/OpenXRay/xray-16/issues/1224
  stdenv = gccStdenv;
in
stdenv.mkDerivation (finalAttrs: {
  pname = "openxray";
  version = "2921-january-2025-rc1";

  src = fetchFromGitHub {
    owner = "OpenXRay";
    repo = "xray-16";
    tag = finalAttrs.version;
    hash = "sha256-PYRC1t4gjT2d41ZZOZJF4u3vc0Pq7DpivEnnfbcSQYk=";
    fetchSubmodules = true;
  };

  # Don't force-override these please
  postPatch = ''
    substituteInPlace Externals/LuaJIT-proj/CMakeLists.txt \
      --replace-fail 'set(CMAKE_OSX_SYSROOT' '#set(CMAKE_OSX_SYSROOT' \
      --replace-fail 'set(ENV{SDKROOT}' '#set(ENV{SDKROOT}'
  '';

  strictDeps = true;

  nativeBuildInputs = [
    cmake
    makeWrapper
  ];

  buildInputs = [
    glew
    liblockfile
    openal
    libtheora
    SDL2
    lzo
    libjpeg
    libogg
    pcre
  ];

  cmakeFlags = [
    # Breaks on Darwin
    (lib.cmakeBool "USE_LTO" (!stdenv.hostPlatform.isDarwin))
  ]
  ++ lib.optionals stdenv.hostPlatform.isDarwin [
    # This seemingly only gets set properly by CMake when using the XCode generator
    (lib.cmakeFeature "CMAKE_OSX_DEPLOYMENT_TARGET" "${stdenv.hostPlatform.darwinMinVersion}")
  ];

  # Because we work around https://github.com/OpenXRay/xray-16/issues/1224 by using GCC,
  # we need a followup workaround for Darwin locale stuff when using GCC:
  # runtime error: locale::facet::_S_create_c_locale name not valid
  postInstall = lib.optionalString stdenv.hostPlatform.isDarwin ''
    wrapProgram $out/bin/xr_3da \
      --run 'export LC_ALL=C'
  '';

  # Crashes can happen, we'd like them to be reasonably debuggable
  cmakeBuildType = "RelWithDebInfo";
  # dlopens its own libraries, relies on rpath not having its prefix stripped
  dontPatchELF = true;
  dontStrip = true;
  passthru.updateScript = gitUpdater { };

  meta = {
    description = "Improved version of the X-Ray Engine, the game engine used in the world-famous S.T.A.L.K.E.R. game series by GSC Game World";
    homepage = "https://github.com/OpenXRay/xray-16/";

    license = lib.licenses.unfree // {
      url = "https://github.com/OpenXRay/xray-16/blob/${finalAttrs.version}/License.txt";
    };

    maintainers = with lib.maintainers; [ OPNA2608 ];

    platforms = [
      "x86_64-linux"
      "i686-linux"
      "aarch64-linux"
      "aarch64-darwin"
    ];

    mainProgram = "xr_3da";
  };
})
