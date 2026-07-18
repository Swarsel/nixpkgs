{
  lib,
  fetchFromGitHub,
  # buildInputs
  SDL2,
  alsa-lib,
  buildPythonPackage,
  # nativeBuildInputs
  cargo,
  glib,
  libpcap,
  # build-system
  meson,
  ninja,
  openal,
  pkg-config,
  # dependencies
  range-typed-integers,
  rustPlatform,
  rustc,
  setuptools,
  setuptools-rust,
  soundtouch,
  zlib,
}:
buildPythonPackage (finalAttrs: {
  pname = "skytemple-ssb-emulator";
  version = "1.8.2";

  src = fetchFromGitHub {
    owner = "SkyTemple";
    repo = "skytemple-ssb-emulator";
    tag = finalAttrs.version;
    hash = "sha256-zmLEvE96gkElTggcRG9fZDrJPLOXeNuSk49zXQAB69Y=";
  };

  nativeBuildInputs = [
    cargo
    ninja
    openal
    pkg-config
    rustPlatform.cargoSetupHook
    rustc
  ];

  buildInputs = [
    SDL2
    alsa-lib
    glib
    libpcap
    soundtouch
    zlib
  ];

  env = {
    # Python 3.14 compatibility
    # error: the configured Python interpreter version (3.14) is newer than PyO3's maximum supported
    # version (3.13)
    PYO3_USE_ABI3_FORWARD_COMPATIBILITY = 1;
  };

  doCheck = false; # there are no tests

  build-system = [
    meson
    setuptools
    setuptools-rust
  ];

  cargoDeps = rustPlatform.fetchCargoVendor {
    inherit (finalAttrs) src pname version;
    hash = "sha256-MSPqQmC70pq+sEM8zJrrFiz32dorOJxr2G/y2H4EUQI=";
  };

  dependencies = [ range-typed-integers ];
  hardeningDisable = [ "format" ];
  pyproject = true;
  pythonImportsCheck = [ "skytemple_ssb_emulator" ];

  meta = {
    description = "SkyTemple Script Engine Debugger Emulator Backend";
    homepage = "https://github.com/SkyTemple/skytemple-ssb-emulator";
    license = lib.licenses.gpl3Plus;
    maintainers = with lib.maintainers; [ marius851000 ];
  };
})
