{
  lib,
  stdenv,
  fetchFromGitHub,
  autoreconfHook,
  libusb1,
  nix-update-script,
}:
stdenv.mkDerivation (finalAttrs: {
  pname = "dfu-programmer";
  version = "1.1.0";

  src = fetchFromGitHub {
    owner = "dfu-programmer";
    repo = "dfu-programmer";
    rev = "v${finalAttrs.version}";
    hash = "sha256-YhiBD8rpzEVVaP3Rdfq74lhZ0Mu7OEbrMsM3fBL1Kvk";
  };

  postPatch = ''
    patchShebangs --build bootstrap.sh
    patchShebangs --build update-bash-completion.sh
  '';

  nativeBuildInputs = [
    autoreconfHook
  ];

  buildInputs = [
    libusb1
  ];

  # No build configured in source, automake requires ChangeLog to exist
  preAutoreconf = ''
    touch ChangeLog
  '';

  passthru.updateScript = nix-update-script { };

  meta = {
    description = "Device Firmware Update based USB programmer for Atmel chips with a USB bootloader";
    homepage = "https://github.com/dfu-programmer/dfu-programmer";
    license = lib.licenses.gpl2;

    maintainers = with lib.maintainers; [
      mbinns
      cybardev
    ];

    platforms = lib.platforms.unix;
    mainProgram = "dfu-programmer";
  };
})
