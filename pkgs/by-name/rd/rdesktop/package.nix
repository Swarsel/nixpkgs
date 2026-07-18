{
  lib,
  stdenv,
  fetchFromGitHub,
  autoreconfHook,
  fetchpatch,
  gnutls,
  krb5,
  libiconv,
  libtasn1,
  libx11,
  libxcursor,
  nettle,
  openssl,
  pkg-config,
  enableCredssp ? (!stdenv.hostPlatform.isDarwin),
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "rdesktop";
  version = "1.9.0";

  src = fetchFromGitHub {
    owner = "rdesktop";
    repo = "rdesktop";
    tag = "v${finalAttrs.version}";
    hash = "sha256-6Kx3giHMDc+5XfPCtjJ3NysCmTnb0TGrR8Mj0bgM0+g=";
  };

  patches = [
    ./rdesktop-configure-c99.patch
    (fetchpatch {
      hash = "sha256-3/y7JaKDyULhlzwP3bsA8kOq7g4AvWUi50gxkCZ8sbU=";
      url = "https://github.com/rdesktop/rdesktop/commit/105c8cb69facf26238cd48f14ca9dbc0ff6be6bd.patch";
    })
    (fetchpatch {
      hash = "sha256-ORGHdabSu9kVkNovweqFVS53dx6NbiryPlgi6Qp83BA=";
      url = "https://github.com/rdesktop/rdesktop/commit/53ba87dc174175e98332e22355ad8662c02880d6.patch";
    })
  ];

  nativeBuildInputs = [
    pkg-config
    autoreconfHook
  ];

  buildInputs = [
    openssl
    libx11
    libxcursor
    libtasn1
    nettle
    gnutls
  ]
  ++ lib.optional enableCredssp krb5
  ++ lib.optional stdenv.hostPlatform.isDarwin libiconv;

  configureFlags = [
    "--with-ipv6"
    "--with-openssl=${openssl.dev}"
    "--disable-smartcard"
  ]
  ++ lib.optional (!enableCredssp) "--disable-credssp";

  meta = {
    description = "Open source client for Windows Terminal Services";
    homepage = "http://www.rdesktop.org/";
    license = lib.licenses.gpl2;
    platforms = lib.platforms.linux ++ lib.platforms.darwin;
    mainProgram = "rdesktop";
  };
})
