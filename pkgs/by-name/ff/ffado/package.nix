{
  lib,
  stdenv,
  fetchurl,
  argp-standalone,
  dbus,
  dbus_cplusplus,
  glibmm,
  libavc1394,
  libconfig,
  libiec61883,
  libraw1394,
  libxmlxx3,
  pkg-config,
  python3,
  qt5,
  scons,
  udevCheckHook,
  which,
  withMixer ? false,
}:

let
  python = python3.withPackages (
    pkgs:
    with pkgs;
    (
      [
        distutils
      ]
      ++ lib.optionals withMixer [
        pyqt5
        dbus-python
      ]
    )
  );
in
stdenv.mkDerivation rec {
  pname = "ffado";
  version = "2.4.9";

  src = fetchurl {
    url = "https://www.ffado.org/files/libffado-${version}.tgz";
    hash = "sha256-xELFL60Ryv1VE7tOhGyFHxAchIT4karFRe0ZDo/U0Q8=";
  };

  outputs = [
    "out"
    "bin"
    "dev"
  ];

  strictDeps = true;

  nativeBuildInputs = [
    scons
    pkg-config
    which
    udevCheckHook
  ]
  ++ lib.optionals withMixer [
    python
    python.pkgs.pyqt5
    qt5.wrapQtAppsHook
  ];

  buildInputs = [
    dbus
    dbus_cplusplus
    glibmm
    libavc1394
    libconfig
    libiec61883
    libraw1394
    libxmlxx3
    python
  ]
  ++ lib.optionals (!stdenv.hostPlatform.isGnu) [
    argp-standalone
  ];

  env = lib.optionalAttrs (!stdenv.hostPlatform.isGnu) {
    NIX_LDFLAGS = "-largp";
  };

  doInstallCheck = true;

  preFixup = lib.optionalString withMixer ''
    wrapQtApp "$bin/bin/ffado-mixer"
  '';

  dontWrapQtApps = true;
  enableParallelBuilding = true;

  prePatch = ''
    substituteInPlace ./support/tools/ffado-diag.in \
      --replace /lib/modules/ "/run/booted-system/kernel-modules/lib/modules/"

    # prevent build tools from leaking into closure
    substituteInPlace support/tools/SConscript --replace-fail \
      'support/tools/ffado-diag --static' \
      "echo '"'See `nix-store --query --tree ${placeholder "out"}`.'"'"
  ''
  + lib.optionalString (!stdenv.buildPlatform.canExecute stdenv.hostPlatform) ''
    # skip the CC sanity check, since that requires invoking cross-compiled binaries during build
    substituteInPlace SConstruct \
      --replace-fail 'conf.CompilerCheck()' 'True' \
      --replace-fail "pkg-config" "$PKG_CONFIG"
    substituteInPlace admin/pkgconfig.py \
      --replace-fail "pkg-config" "$PKG_CONFIG"
  '';

  prefixKey = "PREFIX=";

  sconsFlags = [
    "CUSTOM_ENV=True" # tell SConstruct to use nixpkgs' CC/CXX/CFLAGS
    "DETECT_USERSPACE_ENV=False"
    "DEBUG=False"
    "ENABLE_ALL=True"
    "BUILD_TESTS=True"
    "BUILD_MIXER=${if withMixer then "True" else "False"}"
    "UDEVDIR=${placeholder "out"}/lib/udev/rules.d"
    "PYPKGDIR=${placeholder "out"}/${python.sitePackages}"
    "BINDIR=${placeholder "bin"}/bin"
    "INCLUDEDIR=${placeholder "dev"}/include"
    "PYTHON_INTERPRETER=${python.interpreter}"
  ];

  meta = {
    description = "FireWire audio drivers";
    homepage = "http://www.ffado.org";
    license = lib.licenses.gpl3;

    maintainers = with lib.maintainers; [
      michojel
    ];

    platforms = lib.platforms.linux;
  };
}
