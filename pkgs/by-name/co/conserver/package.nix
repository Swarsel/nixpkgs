{
  lib,
  stdenv,
  fetchFromGitHub,
  autoreconfHook,
  fetchpatch,
  freeipmi,
  libkrb5,
  libxcrypt,
  openssl,
  freeipmiSupport ? false,
  gssapiSupport ? false,
  ipv6Support ? true,
  opensslSupport ? true,
  trustUdsCredSupport ? false,
  udsSupport ? false,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "conserver";
  version = "8.2.7";

  src = fetchFromGitHub {
    owner = "bstansell";
    repo = "conserver";
    rev = "v${finalAttrs.version}";
    sha256 = "sha256-LiCknqitBoa8E8rNMVgp1004CwkW8G4O5XGKe4NfZI8=";
  };

  # Remove upon next release since upstream is fixed
  # https://github.com/bstansell/conserver/pull/82
  patches = [
    (fetchpatch {
      sha256 = "sha256:1dy8r9z7rv8512fl0rk5gi1vl02hnh7x0i6flvpcc13h6r6fhxyc";
      url = "https://github.com/bstansell/conserver/commit/84fc79a459e00dbc87b8cfc943c5045bfcc7aeeb.patch";
    })
  ];

  postPatch = ''
    # install -s calls the wrong strip program when cross compiling
    substituteInPlace \
      console/Makefile.in conserver/Makefile.in autologin/Makefile.in contrib/chat/Makefile.in \
      --replace-fail "@INSTALL_PROGRAM@ -s" "@INSTALL_PROGRAM@"
  '';

  nativeBuildInputs = [ autoreconfHook ];

  buildInputs = [
    libxcrypt
  ]
  ++ lib.optionals freeipmiSupport [ freeipmi ]
  ++ lib.optionals gssapiSupport [ libkrb5 ]
  ++ lib.optionals opensslSupport [ openssl ];

  configureFlags = [
    "--with-ccffile=/dev/null"
    "--with-cffile=/dev/null"
  ]
  ++ lib.optionals freeipmiSupport [ "--with-freeipmi=${freeipmi}/include" ]
  ++ lib.optionals gssapiSupport [ "--with-gssapi=${libkrb5.dev}/include" ]
  ++ lib.optionals ipv6Support [ "--with-ipv6" ]
  ++ lib.optionals opensslSupport [ "--with-openssl=${openssl.dev}/include" ]
  ++ lib.optionals trustUdsCredSupport [ "--with-trust-uds-cred" ]
  ++ lib.optionals udsSupport [ "--with-uds" ];

  # Disabled due to exist upstream cases failing 8/15 tests
  doCheck = false;

  meta = {
    description = "Application that allows multiple users to watch a serial console at the same time";
    homepage = "https://www.conserver.com/";
    license = lib.licenses.bsd3;
    maintainers = with lib.maintainers; [ sarcasticadmin ];
    platforms = lib.platforms.unix;
  };
})
