{
  lib,
  stdenv,
  fetchFromGitHub,
  apacheHttpd,
  autoconf,
  automake,
  autoreconfHook,
  curl,
  glib,
  lasso,
  libtool,
  libxml2,
  libxslt,
  openssl,
  pkg-config,
  xmlsec,
}:

stdenv.mkDerivation rec {

  pname = "mod_auth_mellon";
  version = "0.19.1";

  src = fetchFromGitHub {
    owner = "latchset";
    repo = "mod_auth_mellon";
    rev = "v${version}";
    sha256 = "sha256-VcR+HZ5S7fLrGqT1SHCQLQw6v516G0x+wf8Wb5Sy4Gk=";
  };

  nativeBuildInputs = [
    autoreconfHook
    pkg-config
    autoconf
    automake
  ];

  buildInputs = [
    apacheHttpd
    curl
    glib
    lasso
    libtool
    libxml2
    libxslt
    openssl
    xmlsec
  ];

  configureFlags = [
    "--with-apxs2=${apacheHttpd.dev}/bin/apxs"
    "--exec-prefix=$out"
  ];

  installPhase = ''
    mkdir -p $out/bin
    cp ./mellon_create_metadata.sh $out/bin
    mkdir -p $out/modules
    cp ./.libs/mod_auth_mellon.so $out/modules
  '';

  meta = {
    description = "Apache module with a simple SAML 2.0 service provider";
    homepage = "https://github.com/latchset/mod_auth_mellon";
    license = lib.licenses.gpl2Plus;
    maintainers = with lib.maintainers; [ womfoo ];
    platforms = lib.platforms.linux;
    mainProgram = "mellon_create_metadata.sh";
  };

}
