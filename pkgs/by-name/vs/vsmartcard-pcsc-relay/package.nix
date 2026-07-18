{
  lib,
  stdenv,
  autoreconfHook,
  gengetopt,
  help2man,
  libnfc,
  libtool,
  pcsclite,
  pkg-config,
  python3,
  vsmartcard-vpcd,
}:

stdenv.mkDerivation (finalAttrs: {
  inherit (vsmartcard-vpcd) version src;
  pname = "vsmartcard-pcsc-relay";

  nativeBuildInputs = [
    autoreconfHook
    libtool
    pkg-config
    help2man
  ];

  buildInputs = [
    pcsclite
    libnfc
    gengetopt
    (python3.withPackages (
      pp: with pp; [
        pyscard
        pycrypto
        pbkdf2
        pillow
        gnureadline
      ]
    ))
  ];

  sourceRoot = "${finalAttrs.src.name}/pcsc-relay";

  meta = {
    description = "Relays a smart card using an contact-less interface";
    homepage = "https://frankmorgner.github.io/vsmartcard/pcsc-relay/README.html";
    license = lib.licenses.gpl3Only;
    maintainers = with lib.maintainers; [ stargate01 ];
    platforms = lib.platforms.all;
    broken = stdenv.hostPlatform.isDarwin;
  };
})
