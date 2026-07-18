{
  lib,
  fetchFromGitHub,
  cmake,
  cubeb,
  pkg-config,
  protobuf,
  rustPlatform,
  webrtc,
}:
let
  cubeb' = cubeb.override {
    alsaSupport = false;
    enableShared = false;
    jackSupport = false;
    pulseSupport = true;
    sndioSupport = false;
  };
in
rustPlatform.buildRustPackage (finalAttrs: {
  pname = "ringrtc";
  version = "2.69.3";

  src = fetchFromGitHub {
    owner = "signalapp";
    repo = "ringrtc";
    tag = "v${finalAttrs.version}";
    hash = "sha256-ekSXEaAyVzd5957qoFakD33UYrUmvxZL19M6uflPR5U=";
  };

  nativeBuildInputs = [
    protobuf
    cmake
    pkg-config
  ];

  buildInputs = [
    webrtc
    cubeb'
  ]
  # Workaround for https://github.com/NixOS/nixpkgs/pull/394607
  ++ cubeb'.buildInputs;

  cargoHash = "sha256-oNHT2owg3Ob2z8JxdYnICRdogK+XaasVgbF5RYYBJas=";

  env = {
    LIBCUBEB_STATIC = 1;
    LIBCUBEB_SYS_USE_PKG_CONFIG = 1;
  };

  preConfigure = ''
    # Check for matching webrtc version
    grep 'webrtc.version=${webrtc.version}' config/version.properties
  '';

  doCheck = false;

  cargoBuildFlags = [
    "-p"
    "ringrtc"
    "--features"
    "electron"
  ];

  meta = {
    description = "RingRTC library used by Signal";
    homepage = "https://github.com/signalapp/ringrtc";
    license = lib.licenses.agpl3Only;
    platforms = lib.platforms.unix;
  };
})
