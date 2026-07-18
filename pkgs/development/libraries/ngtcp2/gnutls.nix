{
  lib,
  stdenv,
  fetchFromGitHub,
  autoreconfHook,
  cunit,
  curlWithGnuTls,
  gnutls,
  knot-dns,
  ncurses,
  pkg-config,
}:

stdenv.mkDerivation rec {
  pname = "ngtcp2";
  version = "1.24.0";

  src = fetchFromGitHub {
    owner = "ngtcp2";
    repo = "ngtcp2";
    rev = "v${version}";
    hash = "sha256-RAW31xSZRgrl71zDeWq+7XRHEEw6CdID/41taW0d5ZI=";
  };

  outputs = [
    "out"
    "dev"
  ];

  nativeBuildInputs = [
    autoreconfHook
    pkg-config
  ];

  buildInputs = [ gnutls ];
  configureFlags = [ "--with-gnutls=yes" ];
  doCheck = true;
  nativeCheckInputs = [ cunit ] ++ lib.optional stdenv.hostPlatform.isDarwin ncurses;
  enableParallelBuilding = true;

  passthru.tests = knot-dns.passthru.tests // {
    inherit curlWithGnuTls;
  };

  meta = {
    description = "Effort to implement RFC9000 QUIC protocol";
    homepage = "https://github.com/ngtcp2/ngtcp2";
    license = lib.licenses.mit;

    maintainers = with lib.maintainers; [
      vcunat # for knot-dns
    ];

    platforms = lib.platforms.unix;
  };
}

/*
  Why split from ./default.nix?

  ngtcp2 libs contain helpers to plug into various crypto libs (gnutls, patched openssl, ...).
  Building multiple of them while keeping closures separable would be relatively complicated.
  Separating the builds is easier for now; the missed opportunity to share the 0.3--0.4 MB
  library isn't such a big deal.

  Moreover upstream still commonly does incompatible changes, so agreeing
  on a single version might be hard sometimes.  That's why it seemed simpler
  to completely separate the nix expressions, too.
*/
