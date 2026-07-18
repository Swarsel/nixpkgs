{
  lib,
  fetchFromGitHub,
  alsa-lib,
  pipewire,
  pkg-config,
  rustPlatform,
}:

rustPlatform.buildRustPackage (finalAttrs: {
  pname = "vhost-device-sound";
  version = "0.2.0";

  src = fetchFromGitHub {
    owner = "rust-vmm";
    repo = "vhost-device";
    tag = "vhost-device-sound-v${finalAttrs.version}";
    hash = "sha256-MJRjnJewT1kyy37QzjJ0OToEwdZMZkKxtbyGees/vYU=";
  };

  nativeBuildInputs = [
    pkg-config
    rustPlatform.bindgenHook
  ];

  buildInputs = [
    alsa-lib
    pipewire
  ];

  cargoHash = "sha256-PXJZouhPeylpqX/FLY7pmX+eV+IanRqHSwaJriXFhw8=";
  # Runs dbus-daemon, which tries to load config from /etc.
  doCheck = false;

  cargoBuildFlags = [
    "--package"
    "vhost-device-sound"
  ];

  cargoTestFlags = [
    "--package"
    "vhost-device-sound"
  ];

  meta = {
    description = "virtio-sound device using the vhost-user protocol";
    homepage = "https://github.com/rust-vmm/vhost-device/tree/main/vhost-device-sound";

    license = [
      lib.licenses.asl20
      lib.licenses.bsd3
    ];

    maintainers = [ lib.maintainers.qyliss ];
    platforms = lib.platforms.unix;
  };
})
