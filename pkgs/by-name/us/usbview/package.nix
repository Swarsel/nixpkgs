{
  lib,
  stdenv,
  fetchFromGitHub,
  autoreconfHook,
  gtk3,
  imagemagick,
  pkg-config,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "usbview";
  version = "3.1";

  src = fetchFromGitHub {
    owner = "gregkh";
    repo = "usbview";
    rev = "v${finalAttrs.version}";
    hash = "sha256-h+sB83BYsrB2VxwtatPWNiM0WdTCMY289nh+/0o8GOw=";
  };

  nativeBuildInputs = [
    autoreconfHook
    pkg-config
    imagemagick
  ];

  buildInputs = [
    gtk3
  ];

  meta = {
    description = "USB viewer for Linux";
    homepage = "http://www.kroah.com/linux-usb/";
    license = lib.licenses.gpl2Only;

    maintainers = with lib.maintainers; [
      h7x4
    ];

    platforms = lib.platforms.linux;
    mainProgram = "usbview";
  };
})
