{
  lib,
  stdenv,
  fetchgit,
  gitUpdater,
  libftdi1,
  libgpiod,
  libjaylink,
  libusb1,
  meson,
  ninja,
  pciutils,
  pkg-config,
  withGpio ? stdenv.hostPlatform.isLinux,
  withJlink ? true,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "flashprog";
  version = "1.5";

  src = fetchgit {
    url = "https://review.sourcearcade.org/flashprog";
    tag = "v${finalAttrs.version}";
    hash = "sha256-laU2S7SPFCso/HzPSpbEM6hAE5/XYkNoBqFTT4PU8TU=";
  };

  postPatch = ''
    # Remove these rules from flashprog to avoid conflicts with libftdi
    sed -i"" '/ATTRS{idVendor}=="0403", ATTRS{idProduct}=="6001"/d' "util/50-flashprog.rules"
    sed -i"" '/ATTRS{idVendor}=="0403", ATTRS{idProduct}=="6010"/d' "util/50-flashprog.rules"
    sed -i"" '/ATTRS{idVendor}=="0403", ATTRS{idProduct}=="6011"/d' "util/50-flashprog.rules"
    sed -i"" '/ATTRS{idVendor}=="0403", ATTRS{idProduct}=="6014"/d' "util/50-flashprog.rules"
  '';

  nativeBuildInputs = [
    meson
    ninja
    pkg-config
  ];

  buildInputs = [
    libftdi1
    libusb1
  ]
  ++ lib.optionals (!stdenv.hostPlatform.isDarwin) [
    pciutils
  ]
  ++ lib.optionals withJlink [
    libjaylink
  ]
  ++ lib.optionals withGpio [
    libgpiod
  ];

  postInstall = ''
    install -Dm644 ../util/50-flashprog.rules "$out/lib/udev/rules.d/50-flashprog.rules"
  '';

  doInstallCheck = true;

  passthru.updateScript = gitUpdater {
    allowedVersions = "^[0-9\\.]+$";
    rev-prefix = "v";
  };

  meta = {
    description = "Utility for reading, writing, erasing and verifying flash ROM chips";
    homepage = "https://flashprog.org";
    changelog = "https://flashprog.org/wiki/Flashprog/v${finalAttrs.version}";
    license = with lib.licenses; [ gpl2 ];

    maintainers = with lib.maintainers; [
      felixsinger
      funkeleinhorn
      jmbaur
    ];

    platforms = lib.platforms.all;
    mainProgram = "flashprog";
  };
})
