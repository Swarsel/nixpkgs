{
  lib,
  stdenv,
  fetchFromGitHub,
  autoreconfHook,
  docbook2x,
  docbook_xml_dtd_45,
  libarchive,
  libcap_ng,
  lzo,
  pkg-config,
  zstd,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "icecream";
  version = "1.4";

  src = fetchFromGitHub {
    owner = "icecc";
    repo = "icecream";
    rev = finalAttrs.version;
    sha256 = "sha256-nBdUbWNmTxKpkgFM3qbooNQISItt5eNKtnnzpBGVbd4=";
  };

  nativeBuildInputs = [
    autoreconfHook
    docbook2x
    pkg-config
  ];

  buildInputs = [
    libarchive
    libcap_ng
    lzo
    zstd
    docbook_xml_dtd_45
  ];

  enableParallelBuilding = true;

  meta = {
    inherit (finalAttrs.src.meta) homepage;
    description = "Distributed compiler with a central scheduler to share build load";
    license = lib.licenses.gpl2Plus;
    maintainers = with lib.maintainers; [ emantor ];
    platforms = with lib.platforms; linux ++ darwin;
  };
})
