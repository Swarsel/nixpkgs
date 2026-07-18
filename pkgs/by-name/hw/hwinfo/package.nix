{
  lib,
  stdenv,
  fetchFromGitHub,
  binutils,
  buildPackages,
  flex,
  gitUpdater,
  kmod,
  libuuid,
  libx86emu,
  perl,
  perlPackages,
  runCommand,
  systemdMinimal,
  testers,
  validatePkgConfig,
  writeText,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "hwinfo";
  version = "25.4";

  src = fetchFromGitHub {
    owner = "opensuse";
    repo = "hwinfo";
    rev = finalAttrs.version;
    hash = "sha256-XFb87IuFXYmFnlrjinz7Q+FhoRtpdToW9tos3pFzQYE=";
  };

  outputs = [
    "bin"
    "dev"
    "lib"
    "out"
  ];

  postPatch = ''
    # used by the build system
    echo ${finalAttrs.version} > VERSION

    # Replace /usr paths with Nix store paths
    substituteInPlace Makefile \
      --replace-fail "/sbin" "/bin"
    substituteInPlace src/isdn/cdb/Makefile \
      --replace-fail "lex isdn_cdb.lex" "flex isdn_cdb.lex"
    substituteInPlace hwinfo.pc.in \
      --replace-fail "prefix=/usr" "prefix=$out"
    substituteInPlace src/isdn/cdb/cdb_hwdb.h \
      --replace-fail "/usr/share" "$out/share"

    # Replace /sbin and /usr/bin paths with Nix store paths
    substituteInPlace src/hd/hd_int.h \
      --replace-fail "/sbin/modprobe" "${kmod}/bin/modprobe" \
      --replace-fail "/sbin/rmmod" "${kmod}/bin/rmmod" \
      --replace-fail "/usr/bin/udevinfo" "${systemdMinimal}/bin/udevinfo" \
      --replace-fail "/usr/bin/udevadm" "${systemdMinimal}/bin/udevadm"

    # Replace /usr/bin/perl
    patchShebangs src/ids/convert_hd
  '';

  nativeBuildInputs = [
    flex
    validatePkgConfig
    perl
    perlPackages.XMLWriter
    perlPackages.XMLParser
  ];

  buildInputs = [
    libuuid
    libx86emu
  ];

  makeFlags = [
    "LIBDIR=/lib"
    "CC=${stdenv.cc.targetPrefix}cc"
    "ARCH=${stdenv.hostPlatform.uname.processor}"
  ];

  # The pci/usb ids in hwinfo are ancient. We can get a more up-to-date list simply by copying from systemd
  preBuild = ''
    # since we don't have .git, we cannot run this.
    rm git2log
    pushd src/ids
    cp ${systemdMinimal.src}/hwdb.d/pci.ids src/pci
    cp ${systemdMinimal.src}/hwdb.d/usb.ids src/usb
    # taken from https://github.com/openSUSE/hwinfo/blob/c87f449f1d4882c71b0a1e6dc80638224a5baeed/src/ids/update_pci_usb
    perl -pi -e 'undef $_ if /^C\s/..1' src/usb
    perl ./convert_hd src/pci
    perl ./convert_hd src/usb
    popd

    # build tools for build arch
    make -C src/ids CC=$CC_FOR_BUILD -j $NIX_BUILD_CORES check_hd
    make -C src/isdn/cdb CC=$CC_FOR_BUILD -j $NIX_BUILD_CORES isdn_cdb mk_isdnhwdb
  '';

  postInstall = ''
    moveToOutput bin "$bin"
    moveToOutput lib "$lib"
  '';

  depsBuildBuild = [ buildPackages.stdenv.cc ];
  enableParallelBuilding = false; # broken parallel dependencies

  installFlags = [
    "INSTALL_PREFIX="
    "DESTDIR=$(out)"
  ];

  passthru = {
    tests = {
      version = testers.testVersion { package = finalAttrs.finalPackage; };

      no-usr = testers.testEqualContents {
        actual = runCommand "actual" { nativeBuildInputs = [ binutils ]; } ''
          strings ${finalAttrs.finalPackage}/bin/* | grep /usr/ > $out
        '';

        assertion = "There should be no /usr/ paths in the binaries";

        # There is a bash script that refers to lshal, which is deprecated and not available in Nixpkgs.
        # We'll allow this line, but nothing else.
        expected = writeText "expected" ''
          if [ -x /usr/bin/lshal ] ; then
        '';
      };

      pkg-config = testers.hasPkgConfigModules { package = finalAttrs.finalPackage; };
    };

    updateScript = gitUpdater { };
  };

  meta = {
    description = "Hardware detection tool from openSUSE";
    homepage = "https://github.com/openSUSE/hwinfo";
    license = lib.licenses.gpl2Only;
    maintainers = with lib.maintainers; [ bobvanderlinden ];
    platforms = lib.platforms.linux;
    mainProgram = "hwinfo";
    pkgConfigModules = [ "hwinfo" ];
  };
})
