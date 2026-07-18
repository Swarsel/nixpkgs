{
  lib,
  stdenv,
  fetchFromSourcehut,
  libusb1,
  pkg-config,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "wch-isp";
  version = "0.4.1";

  src = fetchFromSourcehut {
    owner = "~jmaselbas";
    repo = "wch-isp";
    rev = "v${finalAttrs.version}";
    hash = "sha256-JB7cvZPzRhYJ8T3QJkguHOzZFrLOft5rRz0F0sVav/k=";
  };

  nativeBuildInputs = [ pkg-config ];
  buildInputs = [ libusb1 ];
  doInstallCheck = true;

  installFlags = [
    "DESTDIR=$(out)"
    "PREFIX="
  ];

  installTargets = [
    "install"
    "install-rules"
  ];

  meta = {
    description = "Firmware programmer for WCH microcontrollers over USB";
    homepage = "https://git.sr.ht/~jmaselbas/wch-isp";
    license = lib.licenses.gpl2Only;
    maintainers = with lib.maintainers; [ lesuisse ];
    platforms = lib.platforms.unix;
    mainProgram = "wch-isp";
  };
})
