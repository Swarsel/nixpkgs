{
  lib,
  stdenv,
  fetchurl,
  autoreconfHook,
  fetchpatch,
  fping,
  nixosTests,
  perlPackages,
  rrdtool,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "smokeping";
  version = "2.9.0";

  src = fetchurl {
    url = "https://oss.oetiker.ch/smokeping/pub/smokeping-${finalAttrs.version}.tar.gz";
    hash = "sha256-8b41v8zCuhyfdfdtIisptXAk7+icW1ZLhsGjfOLR3bE=";
  };

  patches = [
    (fetchpatch {
      hash = "sha256-97rQ4m9HHl3lIpQyjZvu+gZSrNIB2pckxmopCQAQPp0=";
      url = "https://src.fedoraproject.org/rpms/smokeping/raw/4ebf1921706a5a29c758fdce2f59cc35652c944a/f/smokeping-2.8.2-no-3rd-party.patch";
    })
  ];

  nativeBuildInputs = [ autoreconfHook ];

  propagatedBuildInputs = [
    rrdtool
  ]
  ++ (with perlPackages; [
    perl
    FCGI
    CGI
    CGIFast
    ConfigGrammar
    DigestHMAC
    NetTelnet
    NetOpenSSH
    NetSNMP
    LWP
    LWPProtocolHttps
    IOTty
    fping
    NetDNS
    perlldap
  ]);

  postInstall = ''
    mv $out/htdocs/smokeping.fcgi.dist $out/htdocs/smokeping.fcgi
  '';

  passthru.tests.smokeping = nixosTests.smokeping;

  meta = {
    description = "Network latency collector";
    homepage = "https://oss.oetiker.ch/smokeping";
    license = lib.licenses.gpl2Plus;
    maintainers = [ ];
    platforms = lib.platforms.all;
  };
})
