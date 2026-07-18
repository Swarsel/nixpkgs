{
  lib,
  stdenv,
  fetchFromGitHub,
  perl,
}:

stdenv.mkDerivation {
  pname = "aprx";
  version = "2.9.1-unstable-2021-09-21";

  src = fetchFromGitHub {
    owner = "PhirePhly";
    repo = "aprx";
    rev = "2c84448fe6d897980234961a87ee4c1d4fad69ec";
    hash = "sha256-01PB7FaG8GmPm1U15/3g1CfQwdYmf3ThZFdVh2zUAl4=";
  };

  nativeBuildInputs = [ perl ];

  configureFlags = [
    "--with-erlangstorage"
    "--sbindir=$(out)/bin"
    "--sysconfdir=$(out)/etc"
    "--mandir=$(out)/share/man"
  ];

  makeFlags = [ "INSTALL=install" ];

  env.NIX_CFLAGS_COMPILE = toString [
    "-fcommon"
    "-O2"
    "-Wno-implicit-int" # clang, gcc 14
    "-std=gnu17" # gcc 15
  ];

  preInstall = ''
    mkdir -p $out/bin $out/share/man/man8 $out/etc
  '';

  meta = {
    description = "Multitalented APRS i-gate / digipeater";
    homepage = "http://thelifeofkenneth.com/aprx";
    license = lib.licenses.bsd3;
    maintainers = with lib.maintainers; [ sarcasticadmin ];
    platforms = lib.platforms.unix;
    mainProgram = "aprx";
  };
}
