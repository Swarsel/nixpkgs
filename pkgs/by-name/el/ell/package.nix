{
  lib,
  stdenv,
  autoreconfHook,
  dbus,
  fetchgit,
  gitUpdater,
  pkg-config,
  sysctl,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "ell";
  version = "0.83";

  src = fetchgit {
    url = "https://git.kernel.org/pub/scm/libs/ell/ell.git";
    rev = finalAttrs.version;
    hash = "sha256-RhT36DWIdEpe6WmA7spBt/0peBj4cpy1Qe64/SRBmPs=";
  };

  outputs = [
    "out"
    "dev"
  ];

  nativeBuildInputs = [
    pkg-config
    autoreconfHook
  ];

  # 'unit/test-hwdb' fails in the sandbox as it relies on
  # '/etc/udev/hwdb.bin' file presence in the sandbox. `nixpkgs` does
  # not provide it today in any form. Let's skip the test.
  env.XFAIL_TESTS = "unit/test-hwdb";
  # tests sporadically fail on musl
  doCheck = !stdenv.hostPlatform.isMusl;

  nativeCheckInputs = [
    dbus
    # required as the sysctl test works on some machines
    sysctl
  ];

  enableParallelBuilding = true;
  # Runs multiple dbus instances on the same port failing the bind.
  enableParallelChecking = false;
  separateDebugInfo = true;

  passthru = {
    updateScript = gitUpdater {
      url = "https://git.kernel.org/pub/scm/libs/ell/ell.git";
    };
  };

  meta = {
    description = "Embedded Linux Library";

    longDescription = ''
      The Embedded Linux* Library (ELL) provides core, low-level functionality for system daemons. It typically has no dependencies other than the Linux kernel, C standard library, and libdl (for dynamic linking). While ELL is designed to be efficient and compact enough for use on embedded Linux platforms, it is not limited to resource-constrained systems.
    '';

    homepage = "https://git.kernel.org/pub/scm/libs/ell/ell.git";
    changelog = "https://git.kernel.org/pub/scm/libs/ell/ell.git/tree/ChangeLog?h=${finalAttrs.version}";
    license = lib.licenses.lgpl21Plus;

    maintainers = with lib.maintainers; [
      mic92
    ];

    platforms = lib.platforms.linux;
  };
})
