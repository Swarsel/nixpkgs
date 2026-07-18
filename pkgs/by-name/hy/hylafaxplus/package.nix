{
  lib,
  stdenv,
  fetchurl,
  ## runtime dependencies
  coreutils,
  fakeroot,
  file,
  findutils,
  gawk,
  ghostscript,
  gnugrep,
  gnused,
  libfaketime,
  libtiff,
  libxcrypt,
  openssl,
  psmisc,
  replaceVars,
  sharutils,
  util-linux,
  zlib,
  ## optional packages (using `null` disables some functionality)
  jbigkit ? null,
  lcms2 ? null, # for colored faxes
  ## system-dependent settings that have to be hardcoded
  maxgid ? 65534, # null -> try to auto-detect (bad on linux)
  maxuid ? 65534, # null -> hardcoded value 60002
  openldap ? null,
  pam ? null,
}:

let

  configSite = replaceVars ./config.site {
    inherit coreutils ghostscript libtiff;
    config_maxgid = lib.optionalString (maxgid != null) "CONFIG_MAXGID=${toString maxgid}";
    ghostscript_version = ghostscript.version;
    out = null; # "out" will be resolved in post-install.sh
  };

  postPatch = replaceVars ./post-patch.sh {
    inherit configSite;

    faxcover_binpath = lib.makeBinPath [
      stdenv.shellPackage
      coreutils
    ];

    faxsetup_binpath = lib.makeBinPath [
      stdenv.shellPackage
      coreutils
      findutils
      gnused
      gnugrep
      gawk
    ];

    maxuid = lib.optionalString (maxuid != null) (toString maxuid);
  };

  postInstall = replaceVars ./post-install.sh {
    inherit fakeroot libfaketime;
  };

in

stdenv.mkDerivation (finalAttrs: {
  pname = "hylafaxplus";
  version = "7.0.11";

  src = fetchurl {
    url = "mirror://sourceforge/hylafax/hylafax-${finalAttrs.version}.tar.gz";
    hash = "sha512-JRuJdE17VBrlhVz5GBc2dKBtwzPjljeropcug0bsRvO/8SJvP5PzIP5gbBLpMQKGb77SNp2iNCCOroBOUOn57A==";
  };

  patches = [
    # adjust configure check to work with libtiff > 4.1
    ./libtiff-4.patch
  ];

  postPatch = ". ${postPatch}";

  # Note that `configure` (and maybe `faxsetup`) are looking
  # for a couple of standard binaries in the `PATH` and
  # hardcode their absolute paths in the new package.
  buildInputs = [
    file # for `file` command
    ghostscript
    libtiff
    libxcrypt
    openssl
    psmisc # for `fuser` command
    sharutils # for `uuencode` command
    util-linux # for `agetty` command
    zlib
    jbigkit # optional
    lcms2 # optional
    openldap # optional
    pam # optional
  ];

  postInstall = ". ${postInstall}";
  dontAddPrefix = true;
  postInstallCheck = ". ${./post-install-check.sh}";

  meta = {
    description = "Enterprise-class system for sending and receiving facsimiles";

    longDescription = ''
      HylaFAX is a scalable and time-proven solution
      for sending and receiving facsimiles via modem(s).
      It is based on a client-server architecture,
      loosely comparable to CUPS:
      A client connects to a server to issue outbound jobs,
      the server then chooses a modem to
      connect to the receiving fax machine.
      The server notifies users about their
      outbound jobs as well as about inbound jobs.
      HylaFAX+ is a fork of HylaFAX that -- in general --
      contains a superset of the features of
      HylaFAX and produces releases more often.
      This package contains the client
      and the server parts of HylaFAX+.
    '';

    homepage = "https://hylafax.sourceforge.io";
    changelog = "https://hylafax.sourceforge.io/news/${finalAttrs.version}.php";
    license = lib.licenses.bsd3;
    maintainers = [ lib.maintainers.yarny ];
    platforms = lib.platforms.linux;
    downloadPage = "https://hylafax.sourceforge.io/download.php";
  };
})
