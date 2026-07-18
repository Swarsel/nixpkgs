{
  lib,
  stdenv,
  fetchFromGitHub,
  freebsd,
  nixosTests,
  pkg-config,
  runtimeShell,
  runtimeShellPackage,
  udev,
  enablePrivSep ? false,
  # Always tries to do dynamic linking for udev.
  withUdev ? stdenv.hostPlatform.isLinux && !stdenv.hostPlatform.isStatic,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "dhcpcd";
  version = "10.3.2";

  src = fetchFromGitHub {
    owner = "NetworkConfiguration";
    repo = "dhcpcd";
    rev = "v${finalAttrs.version}";
    sha256 = "sha256-tJV533j/nQT/PP5KVPJCgTo0Lu8NNMIGnJBvYUG8ufw=";
  };

  postPatch = ''
    substituteInPlace hooks/dhcpcd-run-hooks.in --replace /bin/sh ${runtimeShell}
  '';

  nativeBuildInputs = [ pkg-config ];

  buildInputs = [
    runtimeShellPackage # So patchShebangs finds a bash suitable for the installed scripts
  ]
  ++ lib.optionals withUdev [
    udev
  ]
  ++ lib.optionals stdenv.hostPlatform.isFreeBSD [
    freebsd.libcapsicum
    freebsd.libcasper
  ];

  configureFlags = [
    "--sysconfdir=/etc"
    "--localstatedir=/var"
    "--disable-privsep"
    "--dbdir=/var/lib/dhcpcd"
    "--with-default-hostname=nixos"
    (lib.enableFeature enablePrivSep "privsep")
  ]
  ++ lib.optional enablePrivSep "--privsepuser=dhcpcd";

  makeFlags = [ "PREFIX=${placeholder "out"}" ];
  # Check that the udev plugin got built.
  postInstall = lib.optionalString withUdev "[ -e ${placeholder "out"}/lib/dhcpcd/dev/udev.so ]";

  # Hack to make installation succeed.  dhcpcd will still use /var/lib
  # at runtime.
  installFlags = [
    "DBDIR=$(TMPDIR)/db"
    "SYSCONFDIR=${placeholder "out"}/etc"
  ];

  passthru.tests = {
    inherit (nixosTests.networking.scripted)
      macvlan
      dhcpSimple
      dhcpHostname
      dhcpOneIf
      ;
  };

  meta = {
    description = "Client for the Dynamic Host Configuration Protocol (DHCP)";
    homepage = "https://roy.marples.name/projects/dhcpcd";
    license = lib.licenses.bsd2;
    maintainers = [ ];
    platforms = lib.platforms.linux ++ lib.platforms.freebsd ++ lib.platforms.openbsd;
    mainProgram = "dhcpcd";
  };
})
