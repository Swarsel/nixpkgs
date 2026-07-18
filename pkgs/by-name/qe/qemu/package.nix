{
  lib,
  stdenv,
  fetchurl,
  SDL2,
  SDL2_image,
  alsa-lib,
  apple-sdk_15,
  attr,
  bison,
  buildPackages,
  canokey-qemu,
  capstone,
  ceph,
  curl,
  darwin,
  dtc,
  fetchpatch,
  flex,
  fuse3,
  gettext,
  gitUpdater,
  glib,
  glusterfs,
  gnutls,
  gtk3,
  libaio,
  libcacard,
  libcap,
  libcap_ng,
  libcbor,
  libdrm,
  libepoxy,
  libgbm,
  libiscsi,
  libjack2,
  libjpeg,
  libpng,
  libpulseaudio,
  libseccomp,
  libslirp,
  libtasn1,
  libu2f-emu,
  liburing,
  libuuid,
  # TODO: Clean up on `staging`.
  llvmPackages,
  lzo,
  makeWrapper,
  meson,
  ncurses,
  ninja,
  numactl,
  perl,
  pipewire,
  pixman,
  pkg-config,
  python3Packages,
  qemu-utils, # for tests attribute
  removeReferencesTo,
  rutabaga_gfx,
  samba,
  snappy,
  socat,
  spice,
  spice-protocol,
  usbredir,
  valgrind-light,
  vde2,
  virglrenderer,
  vte,
  wrapGAppsHook3,
  xen,
  zlib,
  alsaSupport ? lib.hasSuffix "linux" stdenv.hostPlatform.system && !nixosTestRunner && !minimal,
  canokeySupport ? false,
  capstoneSupport ? !minimal,
  cephSupport ? false,
  enableBlobs ? !minimal || toolsOnly,
  enableDocs ? !minimal || toolsOnly,
  enableTools ? !minimal || toolsOnly,
  fuseSupport ? stdenv.hostPlatform.isLinux && !minimal,
  glusterfsSupport ? false,
  gtkSupport ? !stdenv.hostPlatform.isDarwin && !xenSupport && !nixosTestRunner && !minimal,
  guestAgentSupport ?
    (with stdenv.hostPlatform; isLinux || isNetBSD || isOpenBSD || isSunOS || isWindows) && !minimal,
  hostCpuOnly ? false,
  hostCpuTargets ? (
    if toolsOnly then
      [ ]
    else if xenSupport then
      [ "i386-softmmu" ]
    else if hostCpuOnly then
      (
        lib.optional stdenv.hostPlatform.isx86_64 "i386-softmmu"
        ++ [ "${stdenv.hostPlatform.qemuArch}-softmmu" ]
      )
    else
      null
  ),
  jackSupport ? !stdenv.hostPlatform.isDarwin && !nixosTestRunner && !minimal,
  libiscsiSupport ? !minimal,
  minimal ? toolsOnly || userOnly,
  ncursesSupport ? !nixosTestRunner && !minimal,
  nixosTestRunner ? false,
  numaSupport ? stdenv.hostPlatform.isLinux && !stdenv.hostPlatform.isAarch32 && !minimal,
  openGLSupport ? sdlSupport,
  pipewireSupport ? !stdenv.hostPlatform.isDarwin && !nixosTestRunner && !minimal,
  pluginsSupport ? !stdenv.hostPlatform.isStatic,
  pulseSupport ? !stdenv.hostPlatform.isDarwin && !nixosTestRunner && !minimal,
  rutabagaSupport ?
    openGLSupport && !minimal && lib.meta.availableOn stdenv.hostPlatform rutabaga_gfx,
  sdlSupport ? !stdenv.hostPlatform.isDarwin && !nixosTestRunner && !minimal,
  seccompSupport ? stdenv.hostPlatform.isLinux && !minimal,
  smartcardSupport ? !nixosTestRunner && !minimal,
  smbdSupport ? false,
  spiceSupport ? true && !nixosTestRunner && !minimal,
  toolsOnly ? false,
  tpmSupport ? !minimal,
  u2fEmuSupport ? false,
  uringSupport ? stdenv.hostPlatform.isLinux && !userOnly,
  usbredirSupport ? spiceSupport,
  userOnly ? false,
  valgrindSupport ? false,
  virglSupport ? openGLSupport,
  vncSupport ? !nixosTestRunner && !minimal,
  xenSupport ? false,
}:

assert lib.assertMsg (
  xenSupport -> hostCpuTargets == [ "i386-softmmu" ]
) "Xen should not use any other QEMU architecture other than i386.";

let
  hexagonSupport = hostCpuTargets == null || lib.elem "hexagon" hostCpuTargets;
in

stdenv.mkDerivation (finalAttrs: {
  pname =
    "qemu"
    + lib.optionalString xenSupport "-xen"
    + lib.optionalString hostCpuOnly "-host-cpu-only"
    + lib.optionalString nixosTestRunner "-for-vm-tests"
    + lib.optionalString toolsOnly "-utils"
    + lib.optionalString userOnly "-user";

  version = "11.0.1";

  src = fetchurl {
    url = "https://download.qemu.org/qemu-${finalAttrs.version}.tar.xz";
    hash = "sha256-DSNfWCAnjZFKMVXsJ6+OQljWl+qJKJVXCAfWnAy4zWQ=";
  };

  outputs = [ "out" ] ++ lib.optional enableDocs "doc" ++ lib.optional guestAgentSupport "ga";

  patches = [
    ./fix-qemu-ga.patch

    # On macOS, QEMU uses `Rez(1)` and `SetFile(1)` to attach its icon
    # to the binary. Unfortunately, those commands are proprietary,
    # deprecated since Xcode 6, and operate on resource forks, which
    # these days are stored in extended attributes, which aren’t
    # supported in the Nix store. So we patch out the calls.
    ./skip-macos-icon.patch

    # Workaround for upstream issue with nested virtualisation: https://gitlab.com/qemu-project/qemu/-/issues/1008
    (fetchpatch {
      revert = true;
      sha256 = "sha256-oC+bRjEHixv1QEFO9XAm4HHOwoiT+NkhknKGPydnZ5E=";
      url = "https://gitlab.com/qemu-project/qemu/-/commit/3e4546d5bd38a1e98d4bd2de48631abf0398a3a2.diff";
    })
  ]
  ++ lib.optional nixosTestRunner ./force-uid0-on-9p.patch;

  postPatch = ''
    # Otherwise tries to ensure /var/run exists.
    sed -i "/install_emptydir(get_option('localstatedir') \/ 'run')/d" \
        qga/meson.build
  '';

  nativeBuildInputs = [
    makeWrapper
    removeReferencesTo
    pkg-config
    flex
    bison
    meson
    ninja
    perl

    # For python changes other than simple package additions, ping @dramforever for review.
    # Don't change `python3Packages` to `python3.pkgs.*`, breaks cross-compilation.
    python3Packages.distlib
    python3Packages.setuptools
    python3Packages.wheel
    # Hooks from the python package are needed to add `$pythonPath` so
    # `python/scripts/mkvenv.py` can detect `meson` otherwise the vendored meson without patches will be used.
    python3Packages.python
  ]
  ++ lib.optionals gtkSupport [ wrapGAppsHook3 ]
  ++ lib.optionals enableDocs [
    python3Packages.sphinx
    python3Packages.sphinx-rtd-theme
  ]
  ++ lib.optionals hexagonSupport [ glib ]
  ++ lib.optionals stdenv.hostPlatform.isDarwin [
    darwin.sigtool

    # TODO: Clean up on `staging`.
    llvmPackages.lld
  ]
  ++ lib.optionals (!userOnly) [ dtc ];

  # gnutls is required for crypto support (luks) in qemu-img
  buildInputs = [
    glib
    gnutls
    zlib
  ]
  ++ lib.optionals (!minimal) [
    dtc
    pixman
    vde2
    lzo
    snappy
    libtasn1
    libslirp
    libcbor
  ]
  ++ lib.optionals (!userOnly) [ curl ]
  ++ lib.optionals ncursesSupport [ ncurses ]
  ++ lib.optionals seccompSupport [ libseccomp ]
  ++ lib.optionals numaSupport [ numactl ]
  ++ lib.optionals alsaSupport [ alsa-lib ]
  ++ lib.optionals pulseSupport [ libpulseaudio ]
  ++ lib.optionals pipewireSupport [ pipewire ]
  ++ lib.optionals sdlSupport [
    SDL2
    SDL2_image
  ]
  ++ lib.optionals jackSupport [ libjack2 ]
  ++ lib.optionals gtkSupport [
    gtk3
    gettext
    vte
  ]
  ++ lib.optionals vncSupport [
    libjpeg
    libpng
  ]
  ++ lib.optionals smartcardSupport [ libcacard ]
  ++ lib.optionals spiceSupport [
    spice-protocol
    spice
  ]
  ++ lib.optionals usbredirSupport [ usbredir ]
  ++ lib.optionals (stdenv.hostPlatform.isLinux && !userOnly) [
    libcap_ng
    libcap
    attr
    libaio
  ]
  ++ lib.optionals xenSupport [ xen ]
  ++ lib.optionals cephSupport [ ceph ]
  ++ lib.optionals glusterfsSupport [
    glusterfs
    libuuid
  ]
  ++ lib.optionals openGLSupport [
    libgbm
    libepoxy
    libdrm
  ]
  ++ lib.optionals rutabagaSupport [ rutabaga_gfx ]
  ++ lib.optionals virglSupport [ virglrenderer ]
  ++ lib.optionals libiscsiSupport [ libiscsi ]
  ++ lib.optionals smbdSupport [ samba ]
  ++ lib.optionals uringSupport [ liburing ]
  ++ lib.optionals fuseSupport [ fuse3 ]
  ++ lib.optionals canokeySupport [ canokey-qemu ]
  ++ lib.optionals u2fEmuSupport [ libu2f-emu ]
  ++ lib.optionals capstoneSupport [ capstone ]
  ++ lib.optionals valgrindSupport [ valgrind-light ]
  ++ lib.optionals stdenv.hostPlatform.isDarwin [ apple-sdk_15 ];

  configureFlags = [
    "--disable-strip" # We'll strip ourselves after separating debug info.
    "--enable-gnutls" # auto detection only works when building with --enable-system
    (lib.enableFeature enableDocs "docs")
    (lib.enableFeature enableTools "tools")
    "--localstatedir=/var"
    "--sysconfdir=/etc"
    "--cross-prefix=${stdenv.cc.targetPrefix}"
    (lib.enableFeature guestAgentSupport "guest-agent")
  ]
  ++ lib.optional numaSupport "--enable-numa"
  ++ lib.optional seccompSupport "--enable-seccomp"
  ++ lib.optional smartcardSupport "--enable-smartcard"
  ++ lib.optional spiceSupport "--enable-spice"
  ++ lib.optional usbredirSupport "--enable-usb-redir"
  ++ lib.optional (hostCpuTargets != null) "--target-list=${lib.concatStringsSep "," hostCpuTargets}"
  ++ lib.optionals stdenv.hostPlatform.isDarwin [
    "--enable-cocoa"
    "--enable-hvf"
  ]
  ++ lib.optional (stdenv.hostPlatform.isLinux && !userOnly) "--enable-linux-aio"
  ++ lib.optional gtkSupport "--enable-gtk"
  ++ lib.optional xenSupport "--enable-xen"
  ++ lib.optional cephSupport "--enable-rbd"
  ++ lib.optional glusterfsSupport "--enable-glusterfs"
  ++ lib.optional openGLSupport "--enable-opengl"
  ++ lib.optional virglSupport "--enable-virglrenderer"
  ++ lib.optional tpmSupport "--enable-tpm"
  ++ lib.optional libiscsiSupport "--enable-libiscsi"
  ++ lib.optional smbdSupport "--smbd=${samba}/bin/smbd"
  ++ lib.optional uringSupport "--enable-linux-io-uring"
  ++ lib.optional fuseSupport "--enable-fuse"
  ++ lib.optional canokeySupport "--enable-canokey"
  ++ lib.optional u2fEmuSupport "--enable-u2f"
  ++ lib.optional capstoneSupport "--enable-capstone"
  ++ lib.optional (!pluginsSupport) "--disable-plugins"
  ++ lib.optional (!enableBlobs) "--disable-install-blobs"
  ++ lib.optional userOnly "--disable-system"
  ++ lib.optional stdenv.hostPlatform.isStatic "--static";

  env = lib.optionalAttrs stdenv.hostPlatform.isDarwin {
    NIX_CFLAGS_LINK = "-fuse-ld=lld";
  };

  preConfigure = ''
    unset CPP # intereferes with dependency calculation
    # this script isn't marked as executable b/c it's indirectly used by meson. Needed to patch its shebang
    chmod +x ./scripts/shaderinclude.py
    patchShebangs .
    # avoid conflicts with libc++ include for <version>
    mv VERSION QEMU_VERSION
    substituteInPlace configure \
      --replace-fail '$source_path/VERSION' '$source_path/QEMU_VERSION'
    substituteInPlace meson.build \
      --replace-fail "'VERSION'" "'QEMU_VERSION'"
    substituteInPlace docs/conf.py \
      --replace-fail "'../VERSION'" "'../QEMU_VERSION'"
    substituteInPlace python/qemu/machine/machine.py \
      --replace-fail /var/tmp "$TMPDIR"
  '';

  preBuild = "cd build";
  # tests can still timeout on slower systems
  doCheck = false;

  nativeCheckInputs = [
    python3Packages.pygdbmi
    python3Packages.qemu-qmp
    socat
  ];

  preCheck = ''
    # time limits are a little meagre for a build machine that's
    # potentially under load.
    substituteInPlace ../tests/unit/meson.build \
      --replace 'timeout: slow_tests' 'timeout: 50 * slow_tests'
    substituteInPlace ../tests/qtest/meson.build \
      --replace 'timeout: slow_qtests' 'timeout: 50 * slow_qtests'
    substituteInPlace ../tests/fp/meson.build \
      --replace 'timeout: 90)' 'timeout: 300)'

    # point tests towards correct binaries
    substituteInPlace ../tests/unit/test-qga.c \
      --replace '/bin/bash' "$(type -P bash)" \
      --replace '/bin/echo' "$(type -P echo)"
    substituteInPlace ../tests/unit/test-io-channel-command.c \
      --replace '/bin/socat' "$(type -P socat)"

    # combined with a long package name, some temp socket paths
    # can end up exceeding max socket name len
    substituteInPlace ../tests/qtest/bios-tables-test.c \
      --replace 'qemu-test_acpi_%s_tcg_%s' '%s_%s'

    # get-fsinfo attempts to access block devices, disallowed by sandbox
    sed -i -e '/\/qga\/get-fsinfo/d' -e '/\/qga\/blacklist/d' \
      ../tests/unit/test-qga.c

    # xattrs are not allowed in the sandbox
    substituteInPlace ../tests/qtest/virtio-9p-test.c \
      --replace-fail mapped-xattr mapped-file
  ''
  + lib.optionalString stdenv.hostPlatform.isDarwin ''
    # skip test that stalls on darwin, perhaps due to subtle differences
    # in fifo behaviour
    substituteInPlace ../tests/unit/meson.build \
      --replace "'test-io-channel-command'" "#'test-io-channel-command'"
  '';

  # Add a ‘qemu-kvm’ wrapper for compatibility/convenience.
  postInstall = lib.optionalString (!minimal && !xenSupport) ''
    ln -s $out/bin/qemu-system-${stdenv.hostPlatform.qemuArch} $out/bin/qemu-kvm
  '';

  postFixup = ''
    # the .desktop is both invalid and pointless
    rm -f $out/share/applications/qemu.desktop
  ''
  + lib.optionalString guestAgentSupport ''
    # move qemu-ga (guest agent) to separate output
    mkdir -p $ga/bin
    mv $out/bin/qemu-ga $ga/bin/
    ln -s $ga/bin/qemu-ga $out/bin
    remove-references-to -t $out $ga/bin/qemu-ga
  ''
  + lib.optionalString gtkSupport ''
    # wrap GTK Binaries
    for f in $out/bin/qemu-system-*; do
      wrapGApp $f
    done
  ''
  + lib.optionalString stdenv.hostPlatform.isStatic ''
    # HACK: Otherwise the result will have the entire buildInputs closure
    # injected by the pkgsStatic stdenv
    # <https://github.com/NixOS/nixpkgs/issues/83667>
    rm -f $out/nix-support/propagated-build-inputs
  '';

  depsBuildBuild = [
    buildPackages.stdenv.cc
  ]
  ++ lib.optionals hexagonSupport [ pkg-config ];

  dontAddStaticConfigureFlags = true;
  # QEMU attaches entitlements with codesign and strip removes those,
  # voiding the entitlements and making it non-operational.
  # The alternative is to re-sign with entitlements after stripping:
  # * https://github.com/qemu/qemu/blob/v6.1.0/scripts/entitlement.sh#L25
  dontStrip = stdenv.hostPlatform.isDarwin;
  dontUseMesonConfigure = true; # meson's configurePhase isn't compatible with qemu build
  dontWrapGApps = true;
  # Builds in ~3h with 2 cores, and ~20m with a big-parallel builder.
  requiredSystemFeatures = [ "big-parallel" ];
  separateDebugInfo = true;

  passthru = {
    qemu-system-i386 = "bin/qemu-system-i386";

    tests = lib.optionalAttrs (!toolsOnly) {
      qemu-tests = finalAttrs.finalPackage.overrideAttrs (_: {
        doCheck = true;
      });

      qemu-utils-builds = qemu-utils;
    };

    updateScript = gitUpdater {
      ignoredVersions = "(alpha|beta|rc).*";
      rev-prefix = "v";
      # No nicer place to find latest release.
      url = "https://gitlab.com/qemu-project/qemu.git";
    };
  };

  meta =

    {
      description = "Generic and open source machine emulator and virtualizer";
      homepage = "https://www.qemu.org/";
      license = lib.licenses.gpl2Plus;
      maintainers = with lib.maintainers; [ qyliss ];
      platforms = with lib.systems.inspect; patternLogicalAnd patterns.is64bit patterns.isUnix;
      teams = lib.optionals xenSupport xen.meta.teams;
    }
    # toolsOnly: Does not have qemu-kvm and there's no main support tool
    # userOnly: There's one qemu-<arch> for every architecture
    // lib.optionalAttrs (!toolsOnly && !userOnly) {
      mainProgram = "qemu-kvm";
    }
    # userOnly: https://qemu.readthedocs.io/en/master/user/main.html#supported-operating-systems
    // lib.optionalAttrs userOnly {
      description = "QEMU User space emulator - launch executables compiled for one CPU on another CPU";

      platforms =
        with lib.systems.inspect;
        patternLogicalAnd patterns.is64bit [
          patterns.isLinux
          patterns.isFreeBSD
          patterns.isOpenBSD
          patterns.isNetBSD
        ];
    };
})
