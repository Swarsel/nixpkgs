{
  lib,
  stdenv,
  fetchFromGitHub,
  autoreconfHook,
  efivar,
  keyutils,
  libxcrypt,
  openssl,
  pkg-config,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "mokutil";
  version = "0.7.2";

  src = fetchFromGitHub {
    owner = "lcp";
    repo = "mokutil";
    rev = finalAttrs.version;
    sha256 = "sha256-DO3S1O0AKoI8gssnUyBTRj5lDNs6hhisc/5dTIqmbzM=";
  };

  nativeBuildInputs = [
    autoreconfHook
    pkg-config
  ];

  buildInputs = [
    openssl
    efivar
    keyutils
    libxcrypt
  ];

  meta = {
    description = "Utility to manipulate machines owner keys";
    homepage = "https://github.com/lcp/mokutil";
    license = lib.licenses.gpl3Plus;
    maintainers = with lib.maintainers; [ nickcao ];
    platforms = lib.platforms.linux;
    mainProgram = "mokutil";
  };
})
