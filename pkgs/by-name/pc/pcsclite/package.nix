{
  lib,
  stdenv,
  fetchFromGitLab,
  dbus,
  flex,
  libusb1,
  meson,
  ninja,
  nix-update-script,
  nixosTests,
  perl,
  pkg-config,
  polkit,
  python3,
  systemdLibs,
  testers,
  udev,
  dbusSupport ? stdenv.hostPlatform.isLinux,
  pname ? "pcsclite",
  polkitSupport ? false,
  systemdSupport ? lib.meta.availableOn stdenv.hostPlatform systemdLibs,
  udevSupport ? dbusSupport,
}:

stdenv.mkDerivation (finalAttrs: {
  inherit pname;
  version = "2.4.1";

  src = fetchFromGitLab {
    owner = "rousseau";
    repo = "PCSC";
    tag = finalAttrs.version;
    hash = "sha256-I4kWToLixfkP0XaONiWqNLXXmz+3n+LafbITfZOxLZw=";
    domain = "salsa.debian.org";
  };

  outputs = [
    "out"
    "lib"
    "dev"
    "doc"
    "man"
  ];

  postPatch = ''
    substituteInPlace src/libredirect.c src/spy/libpcscspy.c \
      --replace-fail "libpcsclite_real.so.1" "$lib/lib/libpcsclite_real.so.1"
    substituteInPlace meson.build \
      --replace-fail \
        "install_dir : get_option('sysconfdir') / 'default'" \
        "install_dir : '${placeholder "out"}/etc/default'"
  ''
  + lib.optionalString systemdSupport ''
    substituteInPlace meson.build \
      --replace-fail \
        "systemdsystemunitdir = systemd.get_variable(pkgconfig : 'systemd' + systemdunit + 'unitdir')" \
        "systemdsystemunitdir = '${placeholder "out"}/lib/systemd/system'"
    substituteInPlace meson.build \
      --replace-fail \
        "sysusersdir = systemd.get_variable(pkgconfig : 'sysusersdir')" \
        "sysusersdir = '${placeholder "out"}/lib/sysusers.d'"
  ''
  + lib.optionalString polkitSupport ''
    substituteInPlace meson.build \
      --replace-fail \
        "install_dir : polkit_dep.get_variable('policydir')" \
        "install_dir : '${placeholder "out"}/share/polkit-1/actions'"
  '';

  strictDeps = true;

  nativeBuildInputs = [
    meson
    ninja
    flex
    pkg-config
    perl
  ];

  buildInputs = [
    python3
  ]
  ++ lib.optionals systemdSupport [ systemdLibs ]
  ++ lib.optionals (!systemdSupport && udevSupport) [ udev ]
  ++ lib.optionals dbusSupport [ dbus ]
  ++ lib.optionals polkitSupport [ polkit ]
  ++ lib.optionals (!udevSupport) [ libusb1 ];

  mesonFlags = [
    (lib.mesonOption "sysconfdir" "/etc")
    # The OS should care on preparing the drivers into this location
    (lib.mesonOption "usbdropdir" "/var/lib/pcsc/drivers")
    (lib.mesonBool "libsystemd" systemdSupport)
    (lib.mesonBool "polkit" polkitSupport)
    (lib.mesonOption "ipcdir" "/run/pcscd")
  ]
  ++ lib.optionals systemdSupport [
    (lib.mesonOption "systemdunit" "system")
  ]
  ++ lib.optionals (!udevSupport) [
    (lib.mesonBool "libudev" false)
  ];

  postInstall = ''
    # pcsc-spy is a debugging utility and it drags python into the closure
    moveToOutput bin/pcsc-spy "$dev"
  '';

  __structuredAttrs = true;
  separateDebugInfo = true;

  passthru = {
    tests = {
      version = testers.testVersion {
        command = "pcscd --version";
        package = finalAttrs.finalPackage;
      };

      nixos = nixosTests.pcsclite;
      pkg-config = testers.testMetaPkgConfig finalAttrs.finalPackage;
    };

    updateScript = nix-update-script { };
  };

  meta = {
    description = "Middleware to access a smart card using SCard API (PC/SC)";
    homepage = "https://pcsclite.apdu.fr/";
    changelog = "https://salsa.debian.org/rousseau/PCSC/-/blob/${finalAttrs.version}/ChangeLog";
    license = lib.licenses.bsd3;
    maintainers = [ lib.maintainers.anthonyroussel ];
    platforms = lib.platforms.unix;
    mainProgram = "pcscd";
    broken = !(polkitSupport -> dbusSupport) || !(systemdSupport -> dbusSupport);
    pkgConfigModules = [ "libpcsclite" ];
  };
})
