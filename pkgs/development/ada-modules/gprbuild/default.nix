{
  lib,
  stdenv,
  gnat,
  gprbuild-boot,
  which,
  xmlada,
}:

stdenv.mkDerivation {
  # See ./boot.nix for an explanation of the gprbuild setupHook,
  # our custom knowledge base entry and the situation wrt a
  # (future) gprbuild wrapper.
  inherit (gprbuild-boot)
    version
    src
    setupHooks
    meta
    ;

  pname = "gprbuild";

  patches =
    gprbuild-boot.patches
    # Fixes gprbuild being linked statically always. Based on the AUR's patch:
    # https://aur.archlinux.org/cgit/aur.git/plain/0001-Makefile-build-relocatable-instead-of-static-binary.patch?h=gprbuild&id=bac524c76cd59c68fb91ef4dfcbe427357b9f850
    ++ lib.optionals (!stdenv.hostPlatform.isStatic) [
      ./gprbuild-relocatable-build.patch
    ];

  nativeBuildInputs = [
    gnat
    gprbuild-boot
    which
  ];

  propagatedBuildInputs = [
    xmlada
  ];

  makeFlags = [
    "ENABLE_SHARED=${lib.boolToYesNo (!stdenv.hostPlatform.isStatic)}"
    "PROCESSORS=$(NIX_BUILD_CORES)"
    # confusingly, for gprbuild --target is autoconf --host
    "TARGET=${stdenv.hostPlatform.config}"
    "prefix=${placeholder "out"}"
  ]
  ++ lib.optionals (!stdenv.hostPlatform.isStatic) [
    "LIBRARY_TYPE=relocatable"
  ];

  buildFlags = [
    "all"
    "libgpr.build"
  ];

  env = lib.optionalAttrs stdenv.hostPlatform.isDarwin {
    # Ensure that there is enough space for the `fixDarwinDylibNames` hook to
    # update the install names of the output dylibs.
    NIX_LDFLAGS = "-headerpad_max_install_names";
  };

  # link gprconfig_kb db from gprbuild-boot into build dir,
  # the install process copies its contents to $out
  preInstall = ''
    # Use PATH to discover spliced gprbuild-boot from buildPackages,
    # since path interpolation would give us gprbuild-boot from pkgsHostTarget
    gprbuild_boot="$(dirname "$(type -p gprbuild)")/.."
    ln -sf "$gprbuild_boot/share/gprconfig" share/gprconfig
  '';

  # no need for the install script
  postInstall = ''
    rm $out/doinstall
  '';

  installFlags = [
    "all"
    "libgpr.install"
  ];
}
