{
  lib,
  stdenv,
  fetchFromGitHub,
  cmake,
  freetype,
  harfbuzz,
  imlib2,
  libjpeg,
  libx11,
  ncurses,
  nix-update-script,
  openjpeg,
  pkg-config,
  versionCheckHook,
  zlib,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "jfbview";
  version = "0.7.0";

  src = fetchFromGitHub {
    owner = "jichu4n";
    repo = "jfbview";
    tag = finalAttrs.version;
    hash = "sha256-X52FBg4Jgb80OETu29p4lcWpT+OSRz1xfhw+IkFZr+I=";
    fetchSubmodules = true;
  };

  strictDeps = true;

  nativeBuildInputs = [
    cmake
    pkg-config
  ];

  buildInputs = [
    freetype
    harfbuzz
    imlib2
    libjpeg
    ncurses
    openjpeg
    libx11
    zlib
  ];

  cmakeFlags = [
    (lib.cmakeBool "BUILD_TESTING" false)
    (lib.cmakeFeature "CMAKE_BUILD_TYPE" "Release")
    (lib.cmakeFeature "CMAKE_INSTALL_PREFIX" "/") # relative to $out
  ];

  makeFlags = [ "DESTDIR=${placeholder "out"}" ];
  env.LDFLAGS = "-lImlib2";
  doInstallCheck = true;
  nativeInstallCheckInputs = [ versionCheckHook ];
  __structuredAttrs = true;
  passthru.updateScript = nix-update-script { };

  meta = {
    description = "PDF and image viewer for the Linux framebuffer";
    homepage = "https://github.com/jichu4n/jfbview";
    changelog = "https://github.com/jichu4n/jfbview/releases/tag/${finalAttrs.src.tag}";
    license = lib.licenses.asl20;
    maintainers = with lib.maintainers; [ ulysseszhan ];
    platforms = lib.platforms.linux;
    mainProgram = "jfbview";
  };
})
