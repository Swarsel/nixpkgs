{
  lib,
  stdenv,
  fetchFromGitHub,
  autoreconfHook,
  fcgi,
  pkg-config,
  systemd,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "fcgiwrap";
  version = "1.1.0";

  src = fetchFromGitHub {
    owner = "gnosek";
    repo = "fcgiwrap";
    rev = finalAttrs.version;
    hash = "sha256-znAsZk+aB2XO2NK8Mjc+DLwykYKHolnVQPErlaAx3Oc=";
  };

  # systemd 230 no longer has libsystemd-daemon as a separate entity from libsystemd
  postPatch = ''
    substituteInPlace configure.ac --replace libsystemd-daemon libsystemd
  '';

  nativeBuildInputs = [
    autoreconfHook
    pkg-config
  ];

  buildInputs = [
    systemd
    fcgi
  ];

  configureFlags = [
    "--with-systemd"
    "--with-systemdsystemunitdir=$(out)/etc/systemd/system"
  ];

  env.NIX_CFLAGS_COMPILE = "-Wno-error=implicit-fallthrough";

  meta = {
    description = "Simple server for running CGI applications over FastCGI";
    homepage = "https://github.com/gnosek/fcgiwrap";
    license = lib.licenses.mit;
    maintainers = [ ];
    platforms = with lib.platforms; linux;
    mainProgram = "fcgiwrap";
  };
})
