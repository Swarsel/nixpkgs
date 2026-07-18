{
  lib,
  stdenv,
  fetchFromGitHub,
  cmake,
  curl,
  openssl,
  pkg-config,
  python3,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "osslsigncode";
  version = "2.13";

  src = fetchFromGitHub {
    owner = "mtrojnar";
    repo = "osslsigncode";
    rev = finalAttrs.version;
    sha256 = "sha256-63SIyjG91i6ldA3NpOG5X5fT8vTRqNaXDtOE/ZStqFA=";
  };

  nativeBuildInputs = [
    cmake
    pkg-config
    python3
  ];

  buildInputs = [
    curl
    openssl
  ];

  meta = {
    description = "OpenSSL based Authenticode signing for PE/MSI/Java CAB files";
    homepage = "https://github.com/mtrojnar/osslsigncode";
    license = lib.licenses.gpl3Plus;

    maintainers = with lib.maintainers; [
      mmahut
      prusnak
    ];

    platforms = lib.platforms.all;
    mainProgram = "osslsigncode";
  };
})
