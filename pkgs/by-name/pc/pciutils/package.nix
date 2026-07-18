{
  lib,
  stdenv,
  fetchFromGitHub,
  gitUpdater,
  hwdata,
  kmod,
  pkg-config,
  which,
  zlib,
  static ? stdenv.hostPlatform.isStatic,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "pciutils";
  version = "3.15.0"; # with release-date database

  src = fetchFromGitHub {
    owner = "pciutils";
    repo = "pciutils";
    rev = "v${finalAttrs.version}";
    hash = "sha256-fPtOhUz8Hlo0ajCZbNOwT4fiuL8HlFQ7NGk+nQpmKZM=";
  };

  # Since this package doesn't use an autotools generated configure script,
  # splitting the dev or lib outputs produces incorrect files, evident by e.g
  # pkg-config files which point to wrong paths. manual pages OTH are moved to
  # the $man outputs naturally by stdenv.
  outputs = [
    "out"
    "man"
  ];

  nativeBuildInputs = [ pkg-config ];

  buildInputs = [
    which
    zlib
  ]
  ++ lib.optionals stdenv.hostPlatform.isLinux [ kmod ];

  makeFlags = [
    "SHARED=${lib.boolToYesNo (!static)}"
    "PREFIX=\${out}"
    "STRIP="
    "HOST=${stdenv.hostPlatform.system}"
    "CROSS_COMPILE=${stdenv.cc.targetPrefix}"
    "DNS=yes"
  ];

  preConfigure = lib.optionalString (!stdenv.cc.isGNU) ''
    substituteInPlace Makefile --replace 'CC=$(CROSS_COMPILE)gcc' ""
  '';

  postInstall = ''
    # Remove update-pciids as it won't work on nixos
    rm $out/sbin/update-pciids $out/man/man8/update-pciids.8

    # use database from hwdata instead
    # (we don't create a symbolic link because we do not want to pull in the
    # full closure of hwdata)
    cp --reflink=auto ${hwdata}/share/hwdata/pci.ids $out/share/pci.ids
  '';

  enableParallelBuilding = true;

  installTargets = [
    "install"
    "install-lib"
  ];

  passthru.updateScript = gitUpdater {
    rev-prefix = "v";
    # No nicer place to find latest release.
    url = "https://github.com/pciutils/pciutils.git";
  };

  meta = {
    description = "Collection of programs for inspecting and manipulating configuration of PCI devices";
    homepage = "https://mj.ucw.cz/sw/pciutils/";
    license = lib.licenses.gpl2Plus;
    maintainers = [ lib.maintainers.vcunat ]; # not really, but someone should watch it
    platforms = lib.platforms.unix;
    mainProgram = "lspci";
  };
})
