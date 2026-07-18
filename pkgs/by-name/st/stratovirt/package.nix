{
  lib,
  alsa-lib,
  cyrus_sasl,
  fetchgit,
  gtk3,
  libcap_ng,
  libpulseaudio,
  libseccomp,
  libusbgx,
  linuxHeaders,
  pixman,
  pkg-config,
  rustPlatform,
}:

rustPlatform.buildRustPackage (finalAttrs: {
  pname = "stratovirt";
  version = "2.4.0";

  src = fetchgit {
    url = "https://gitee.com/openeuler/stratovirt.git";
    rev = "v${finalAttrs.version}";
    hash = "sha256-1Ex6ahKBoVRikSqrgHGYaBFzWkPFDm8bGVyB7KmO8tI=";
  };

  nativeBuildInputs = [
    pkg-config
    rustPlatform.bindgenHook
  ];

  buildInputs = [
    pixman
    libcap_ng
    cyrus_sasl
    libpulseaudio
    gtk3
    libusbgx
    alsa-lib
    linuxHeaders
    libseccomp
  ];

  cargoHash = "sha256-tNFF5WdQyNqkj2ahtpOfGTHriHpMGtV1UurO3teKFcU=";

  meta = {
    description = "Virtual Machine Manager from Huawei";
    homepage = "https://gitee.com/openeuler/stratovirt";
    license = lib.licenses.mulan-psl2;
    maintainers = with lib.maintainers; [ astro ];

    platforms = [
      "aarch64-linux"
      "x86_64-linux"
    ];

    mainProgram = "stratovirt";
  };
})
