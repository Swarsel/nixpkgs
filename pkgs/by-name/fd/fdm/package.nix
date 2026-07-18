{
  lib,
  stdenv,
  fetchFromGitHub,
  autoreconfHook,
  bison,
  flex,
  openssl,
  tdb,
  zlib,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "fdm";
  version = "2.2";

  src = fetchFromGitHub {
    owner = "nicm";
    repo = "fdm";
    rev = finalAttrs.version;
    hash = "sha256-Gqpz+N1ELU5jQpPJAG9s8J9UHWOJNhkT+s7+xuQazd0=";
  };

  nativeBuildInputs = [ autoreconfHook ];

  buildInputs = [
    openssl
    tdb
    zlib
    flex
    bison
  ];

  postInstall = ''
    install fdm-sanitize $out/bin
    mkdir -p $out/share/doc/fdm
    install -m644 MANUAL $out/share/doc/fdm
    cp -R examples $out/share/doc/fdm
  '';

  meta = {
    description = "Mail fetching and delivery tool - should do the job of getmail and procmail";
    homepage = "https://github.com/nicm/fdm";
    license = lib.licenses.isc;
    maintainers = with lib.maintainers; [ raskin ];
    platforms = with lib.platforms; linux ++ darwin;
    downloadPage = "https://github.com/nicm/fdm/releases";
  };
})
