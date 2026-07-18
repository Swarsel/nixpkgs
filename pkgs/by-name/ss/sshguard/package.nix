{
  lib,
  stdenv,
  fetchurl,
  autoreconfHook,
  bison,
  flex,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "sshguard";
  version = "2.5.1";

  src = fetchurl {
    url = "mirror://sourceforge/sshguard/sshguard-${finalAttrs.version}.tar.gz";
    sha256 = "sha256-mXoeDsKyFltHV8QviUgWLrU0GDlGr1LvxAaIXZfLifw=";
  };

  nativeBuildInputs = [
    autoreconfHook
    bison
    flex
  ];

  configureFlags = [ "--sysconfdir=/etc" ];
  doCheck = true;

  meta = {
    description = "Protects hosts from brute-force attacks";

    longDescription = ''
      SSHGuard can read log messages from various input sources. Log messages are parsed, line-by-line, for recognized patterns.
      If an attack, such as several login failures within a few seconds, is detected, the offending IP is blocked.
    '';

    homepage = "https://sshguard.net";
    license = lib.licenses.bsd3;
    maintainers = [ ];
    platforms = with lib.platforms; linux ++ darwin ++ freebsd ++ netbsd ++ openbsd;
    mainProgram = "sshguard";
  };
})
