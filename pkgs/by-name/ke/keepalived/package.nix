{
  lib,
  stdenv,
  fetchFromGitHub,
  autoreconfHook,
  file,
  libmnl,
  libnftnl,
  libnl,
  net-snmp,
  nixosTests,
  openssl,
  pkg-config,
  withNetSnmp ? stdenv.buildPlatform.canExecute stdenv.hostPlatform,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "keepalived";
  version = "2.3.4";

  src = fetchFromGitHub {
    owner = "acassen";
    repo = "keepalived";
    rev = "v${finalAttrs.version}";
    sha256 = "sha256-Xv/UGIeZhRHQO5lxkaWgHDUW+3qBi3wFU4+Us1A2uE0=";
  };

  nativeBuildInputs = [
    pkg-config
    autoreconfHook
  ];

  buildInputs = [
    file
    libmnl
    libnftnl
    libnl
    openssl
  ]
  ++ lib.optionals withNetSnmp [
    net-snmp
  ];

  configureFlags = [
    "--enable-sha1"
  ]
  ++ lib.optionals withNetSnmp [
    "--enable-snmp"
  ];

  enableParallelBuilding = true;
  passthru.tests = nixosTests.keepalived;

  meta = {
    description = "Routing software written in C";
    homepage = "https://keepalived.org";
    license = lib.licenses.gpl2Plus;
    maintainers = [ lib.maintainers.raitobezarius ];
    platforms = lib.platforms.linux;
    mainProgram = "keepalived";
  };
})
