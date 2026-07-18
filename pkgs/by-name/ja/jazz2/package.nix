{
  lib,
  stdenv,
  fetchFromGitHub,
  SDL2,
  cmake,
  curl,
  gitUpdater,
  jazz2-content,
  libGL,
  libopenmpt,
  libvorbis,
  openal,
  versionCheckHook,
  zlib,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "jazz2";
  version = "3.6.0";

  src = fetchFromGitHub {
    owner = "deathkiller";
    repo = "jazz2-native";
    tag = finalAttrs.version;
    hash = "sha256-Ijm5OyQT5JceF9hDLX4z9BZfTY/XYtSdmpMfjgqzCe4=";
  };

  patches = [ ./nocontent.patch ];
  strictDeps = true;
  nativeBuildInputs = [ cmake ];

  buildInputs = [
    curl
    libGL
    libopenmpt
    libvorbis
    openal
    SDL2
    zlib
  ];

  cmakeFlags = [
    (lib.cmakeBool "NCINE_DOWNLOAD_DEPENDENCIES" false)
    (lib.cmakeFeature "LIBOPENMPT_INCLUDE_DIR" "${lib.getDev libopenmpt}/include/libopenmpt")
    (lib.cmakeFeature "NCINE_OVERRIDE_CONTENT_PATH" "${jazz2-content}")
  ];

  doInstallCheck = true;

  nativeInstallCheckInputs = [
    versionCheckHook
  ];

  passthru = {
    updateScript = gitUpdater { };
  };

  meta = {
    description = "Open-source Jazz Jackrabbit 2 reimplementation";
    homepage = "https://github.com/deathkiller/jazz2-native";
    license = lib.licenses.gpl3Only;
    maintainers = with lib.maintainers; [ surfaceflinger ];
    platforms = lib.platforms.linux;
    mainProgram = "jazz2";
  };
})
