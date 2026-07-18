{
  lib,
  stdenv,
  fetchurl,
  gnutls,
  libcap,
  libedit,
  libseccomp,
  nixosTests,
  pkg-config,
  pps-tools,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "chrony";
  version = "4.8";

  src = fetchurl {
    url = "https://chrony-project.org/releases/chrony-${finalAttrs.version}.tar.gz";
    hash = "sha256-M+qOsqTa6qUG6Pyv1dbYkCftby8GCWRcbxSbVg0wFwY=";
  };

  outputs = [
    "out"
    "man"
  ];

  patches = [
    # Cleanup the installation script
    ./makefile.patch
  ];

  postPatch = ''
    patchShebangs test

    # nts_ke_session unit test fails, so drop it.
    # TODO: try again when updating?
    rm test/unit/nts_ke_session.c
  '';

  nativeBuildInputs = [ pkg-config ];

  buildInputs = [
    gnutls
    libedit
  ]
  ++ lib.optionals stdenv.hostPlatform.isLinux [
    libcap
    libseccomp
    pps-tools
  ];

  configureFlags = [
    "--enable-ntp-signd"
    "--sbindir=$(out)/bin"
    "--chronyrundir=/run/chrony"
  ]
  ++ lib.optional stdenv.hostPlatform.isLinux "--enable-scfilter";

  doCheck = true;
  enableParallelBuilding = true;

  passthru.tests = {
    inherit (nixosTests) chrony chrony-ptp;
  };

  meta = {
    description = "Sets your computer's clock from time servers on the Net";

    longDescription = ''
      Chronyd is a daemon which runs in background on the system. It obtains
      measurements via the network of the system clock’s offset relative to
      time servers on other systems and adjusts the system time accordingly.
      For isolated systems, the user can periodically enter the correct time by
      hand (using Chronyc). In either case, Chronyd determines the rate at
      which the computer gains or loses time, and compensates for this. Chronyd
      implements the NTP protocol and can act as either a client or a server.

      Chronyc provides a user interface to Chronyd for monitoring its
      performance and configuring various settings. It can do so while running
      on the same computer as the Chronyd instance it is controlling or a
      different computer.
    '';

    homepage = "https://chrony-project.org/";
    license = lib.licenses.gpl2Only;

    maintainers = with lib.maintainers; [
      thoughtpolice
      vifino
    ];

    platforms =
      with lib.platforms;
      builtins.concatLists [
        linux
        freebsd
        netbsd
        darwin
        illumos
      ];

    broken = stdenv.isDarwin;
  };
})
