{
  lib,
  stdenv,
  fetchFromGitHub,
  autoreconfHook,
  gnutls,
  libmnl,
  liburing,
  libusb1,
  lksctp-tools,
  pcsclite,
  pkg-config,
  python3,
  talloc,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "libosmocore";
  version = "1.13.1";

  src = fetchFromGitHub {
    owner = "osmocom";
    repo = "libosmocore";
    rev = finalAttrs.version;
    hash = "sha256-lHPpV3wmsJFzanMUF6dhhmKTVCIz5MOfqr8U23sm6eI=";
  };

  postPatch = ''
    echo "${finalAttrs.version}" > .tarball-version
  '';

  nativeBuildInputs = [
    autoreconfHook
    pkg-config
    python3
  ];

  buildInputs = [
    gnutls
    liburing
    libusb1
    lksctp-tools
    pcsclite
  ];

  propagatedBuildInputs = [
    talloc
    libmnl
  ];

  enableParallelBuilding = true;

  meta = {
    description = "Set of Osmocom core libraries";
    homepage = "https://github.com/osmocom/libosmocore";
    license = lib.licenses.gpl2Plus;

    maintainers = with lib.maintainers; [
      mog
    ];

    platforms = lib.platforms.linux;
  };
})
