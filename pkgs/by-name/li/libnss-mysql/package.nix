{
  lib,
  stdenv,
  fetchFromGitHub,
  autoreconfHook,
  libmysqlclient,
  nixosTests,
  which,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "libnss-mysql";
  version = "1.7.2";

  src = fetchFromGitHub {
    owner = "saknopper";
    repo = "libnss-mysql";
    rev = "v${finalAttrs.version}";
    sha256 = "sha256-/oeUe94NfOzKrHhiIEW0cMXP5pAqPHulRO82JwPrv5I=";
  };

  nativeBuildInputs = [
    autoreconfHook
    which
  ];

  buildInputs = [ libmysqlclient ];
  configureFlags = [ "--sysconfdir=/etc" ];

  postInstall = ''
    rm -r $out/etc
  '';

  installFlags = [ "sysconfdir=$(out)/etc" ];

  passthru.tests = {
    inherit (nixosTests) auth-mysql;
  };

  meta = {
    description = "MySQL module for the Solaris Nameservice Switch (NSS)";
    homepage = "https://github.com/saknopper/libnss-mysql";
    license = lib.licenses.gpl2Plus;
    maintainers = with lib.maintainers; [ netali ];
    platforms = lib.platforms.linux;
  };
})
