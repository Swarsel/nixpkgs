{
  lib,
  stdenv,
  apparmor-bin-utils,
  apparmor-parser,
  buildPackages,
  coreutils,
  gnugrep,
  # runtime deps
  gnused,
  # apparmor deps
  libapparmor,
  perl,
  replaceVars,
  runtimeShellPackage,
  systemd,
  which,
}:
stdenv.mkDerivation (finalAttrs: {
  inherit (libapparmor) version src;
  pname = "apparmor-init";

  patches = [
    (replaceVars ./fix-rc-apparmor-functions-FHS.patch {
      PATH = lib.makeBinPath [
        # bash script needs a bunch of binaries, but we can't wrapProgram because it is more a library that will be used with `source`
        apparmor-bin-utils
        apparmor-parser
        coreutils
        gnused
        gnugrep
        systemd
      ];
    })
  ];

  postPatch = ''
    patchShebangs .

    substituteInPlace apparmor.service \
      --replace-fail "/bin/true" "${lib.getExe' coreutils "true"}"

    # the various provided scripts hardcode /lib/apparmor
    for FILE in aa-teardown apparmor.service apparmor.systemd profile-load
    do
      substituteInPlace "$FILE" \
        --replace-fail "/lib/apparmor" "$out/lib/apparmor"
    done
  '';

  strictDeps = true;

  nativeBuildInputs = [
    which
    perl
  ];

  buildInputs = [
    runtimeShellPackage
  ];

  makeFlags = [
    "POD2MAN=${lib.getExe' buildPackages.perl "pod2man"}"
    "POD2HTML=${lib.getExe' buildPackages.perl "pod2html"}"
    "MANDIR=share/man"
  ];

  doCheck = true;
  __structuredAttrs = true;

  installFlags = [
    "DESTDIR=${placeholder "out"}"
    "DISTRO=unknown"
    "USR_SBINDIR=${placeholder "out"}/bin"
    "SBINDIR=${placeholder "out"}/bin"
    "LOCALEDIR=${placeholder "out"}/share/locale"
    "SYSTEMD_UNIT_DIR=${placeholder "out"}/lib/systemd/system"
  ];

  installTargets = [
    "install"
    # Likely not very useful for NixOS, as this is missing some NixOS awareness such as loading declarative profiles from the store
    # However, the cost is low, it may be useful in the future or on non-NixOS systems, so install the systemd service too.
    "install-systemd"
  ];

  sourceRoot = "${finalAttrs.src.name}/init";

  meta = libapparmor.meta // {
    description = "Mandatory access control system - init files";
  };
})
