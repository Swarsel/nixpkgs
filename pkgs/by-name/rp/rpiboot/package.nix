{
  lib,
  stdenv,
  fetchFromGitHub,
  gitUpdater,
  libusb1,
  pkg-config,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "rpiboot";
  version = "20250908-162618-bookworm";

  src = fetchFromGitHub {
    owner = "raspberrypi";
    repo = "usbboot";
    tag = finalAttrs.version;
    hash = "sha256-BJOm8VBEbrUasYwuV8NqwmsolJzmaqIaxYqj9EkU5hc=";
    fetchSubmodules = true;
  };

  nativeBuildInputs = [ pkg-config ];
  buildInputs = [ libusb1 ];
  makeFlags = [ "INSTALL_PREFIX=$(out)" ];

  preInstall = ''
    mkdir -p $out/bin
  '';

  passthru.updateScript = gitUpdater { };

  meta = {
    description = "Utility to boot a Raspberry Pi CM/CM3/CM4/Zero over USB";
    homepage = "https://github.com/raspberrypi/usbboot";
    changelog = "https://github.com/raspberrypi/usbboot/blob/${finalAttrs.version}/debian/changelog";
    license = lib.licenses.asl20;

    maintainers = with lib.maintainers; [
      flokli
      stv0g
    ];

    platforms = [
      "aarch64-linux"
      "aarch64-darwin"
      "armv7l-linux"
      "armv6l-linux"
      "x86_64-linux"
    ];

    mainProgram = "rpiboot";
  };
})
