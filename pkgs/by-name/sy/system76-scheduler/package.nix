{
  lib,
  fetchFromGitHub,
  bcc,
  dbus,
  pipewire,
  pkg-config,
  rustPlatform,
}:

let
  version = "2.0.2-unstable-2025-01-15";
in
rustPlatform.buildRustPackage {
  inherit version;
  pname = "system76-scheduler";

  src = fetchFromGitHub {
    owner = "pop-os";
    repo = "system76-scheduler";
    rev = "b0b7e98b0dbd2cd05e9fe80829e7083048202da7";
    hash = "sha256-I+LN7Q5/VQ203Vk0eKM4HZw8oSS0bkcY/wIWbu4hPnI=";
  };

  nativeBuildInputs = [
    pkg-config
    rustPlatform.bindgenHook
  ];

  buildInputs = [
    dbus
    pipewire
  ];

  cargoHash = "sha256-rTe016jxRdL3xOw6yHz8btyfnecGuPTIashKQustYP0=";
  env.EXECSNOOP_PATH = "${bcc}/bin/execsnoop";
  # tests don't build
  doCheck = false;

  postInstall = ''
    mkdir -p $out/data
    install -D -m 0644 data/com.system76.Scheduler.conf $out/etc/dbus-1/system.d/com.system76.Scheduler.conf
    install -D -m 0644 data/*.kdl $out/data/
  '';

  meta = {
    description = "System76 Scheduler";
    homepage = "https://github.com/pop-os/system76-scheduler";
    license = lib.licenses.mpl20;
    maintainers = [ lib.maintainers.cmm ];

    platforms = [
      "x86_64-linux"
      "x86-linux"
      "aarch64-linux"
    ];

    mainProgram = "system76-scheduler";
  };
}
