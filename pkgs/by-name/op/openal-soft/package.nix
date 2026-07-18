{
  lib,
  stdenv,
  fetchFromGitHub,
  alsa-lib,
  cmake,
  dbus,
  libpulseaudio,
  nix-update-script,
  pipewire,
  pkg-config,
  removeReferencesTo,
  testers,
  alsaSupport ? stdenv.hostPlatform.isLinux,
  dbusSupport ? !stdenv.hostPlatform.isDarwin,
  pipewireSupport ? !stdenv.hostPlatform.isDarwin,
  pulseSupport ? !stdenv.hostPlatform.isDarwin,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "openal-soft";
  version = "1.24.3";

  src = fetchFromGitHub {
    owner = "kcat";
    repo = "openal-soft";
    tag = finalAttrs.version;
    hash = "sha256-VQa3FD9NyvDv/+VbU+5lmV0LteiioJHpRkr1lnCn1g4=";
  };

  strictDeps = true;

  nativeBuildInputs = [
    cmake
    pkg-config
    removeReferencesTo
  ];

  buildInputs =
    lib.optional alsaSupport alsa-lib
    ++ lib.optional dbusSupport dbus
    ++ lib.optional pipewireSupport pipewire
    ++ lib.optional pulseSupport libpulseaudio;

  cmakeFlags = [
    # Automatically links dependencies without having to rely on dlopen, thus
    # removes the need for NIX_LDFLAGS.
    (lib.cmakeBool "ALSOFT_DLOPEN" false)
    # allow oal-soft to find its own data files (e.g. HRTF profiles)
    (lib.cmakeBool "ALSOFT_SEARCH_INSTALL_DATADIR" true)
  ];

  passthru = {
    tests.pkg-config = testers.testMetaPkgConfig finalAttrs.finalPackage;

    updateScript = nix-update-script {
      extraArgs = [
        "--version-regex"
        "^(\\d+\\.\\d+\\.\\d+)$"
      ];
    };
  };

  meta = {
    description = "OpenAL alternative";
    homepage = "https://openal-soft.org/";
    changelog = "https://github.com/kcat/openal-soft/blob/master/ChangeLog";
    license = lib.licenses.lgpl2;
    maintainers = [ ];
    platforms = lib.platforms.unix;
    pkgConfigModules = [ "openal" ];
  };
})
