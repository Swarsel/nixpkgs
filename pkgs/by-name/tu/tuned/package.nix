{
  lib,
  stdenv,
  fetchFromGitHub,
  asciidoctor,
  desktop-file-utils,
  dmidecode,
  ethtool,
  gawk,
  gobject-introspection,
  hdparm,
  iproute2,
  kmod,
  nix-update-script,
  nixosTests,
  pkg-config,
  powertop,
  python3Packages,
  tuna,
  util-linux,
  versionCheckHook,
  virt-what,
  wirelesstools,
  wrapGAppsHook3,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "tuned";
  version = "2.27.0";

  src = fetchFromGitHub {
    owner = "redhat-performance";
    repo = "tuned";
    tag = "v${finalAttrs.version}";
    hash = "sha256-PlF2T+EpveFkKPMU/6ZMXDO0q8Efzol4HJ4CX0wsBoY=";
  };

  outputs = [
    "out"
    "doc"
    "man"
  ];

  patches = [
    # Some tests require a TTY to run
    ./remove-tty-tests.patch
  ];

  postPatch = ''
    patchShebangs .

    substituteInPlace tuned-gui.py tuned.service tuned/ppd/tuned-ppd.service \
      --replace-fail "/usr/sbin/" "$out/bin/"

    substituteInPlace tuned-gui.desktop \
      --replace-fail "/usr/sbin/tuned-gui" "tuned-gui"

    substituteInPlace experiments/powertop2tuned.py \
      --replace-fail "/usr/sbin/powertop" "${lib.getExe powertop}"

    substituteInPlace \
      tuned/{gtk/tuned_dialog.py,consts.py} tuned-gui.py tuned-adm.bash \
      $(find profiles/ -type f -executable -name '*.sh') \
      --replace-warn "/usr/share" "$out/share" \
      --replace-warn "/usr/lib" "$out/lib"
  '';

  strictDeps = true;

  nativeBuildInputs = [
    asciidoctor
    desktop-file-utils
    gobject-introspection
    pkg-config
    wrapGAppsHook3
    python3Packages.wrapPython
  ];

  propagatedBuildInputs = with python3Packages; [
    dbus-python
    pygobject3
    pyinotify
    pyperf
    python-linux-procfs
    pyudev
    tuna
  ];

  makeFlags = [
    "DESTDIR=${placeholder "out"}"
    "PREFIX="

    "PYTHON=${lib.getExe python3Packages.python}"
    "PYTHON_SITELIB=/${python3Packages.python.sitePackages}"
    "TMPFILESDIR=/lib/tmpfiles.d"
    "UNITDIR=/lib/systemd/system"
  ];

  doCheck = stdenv.buildPlatform.canExecute stdenv.hostPlatform;

  postInstall = ''
    rm -rf $out/{run,var}
  '';

  doInstallCheck = true;

  nativeInstallCheckInputs = [
    python3Packages.pythonImportsCheckHook
    versionCheckHook
  ];

  postFixup = ''
    wrapPythonPrograms
  '';

  checkTarget = "test";
  dontWrapGApps = true;

  installTargets = [
    "install"
    "install-ppd"
  ];

  makeWrapperArgs = [
    "\${gappsWrapperArgs[@]}"
    "--prefix"
    "PATH"
    ":"
    (lib.makeBinPath [
      dmidecode
      ethtool
      gawk
      hdparm
      iproute2
      kmod
      util-linux
      virt-what
      wirelesstools
    ])
  ];

  pythonImportsCheck = [ "tuned" ];

  passthru = {
    tests = lib.optionalAttrs stdenv.hostPlatform.isLinux {
      nixos = nixosTests.tuned;
    };

    updateScript = nix-update-script { };
  };

  meta = {
    description = "Tuning Profile Delivery Mechanism for Linux";
    homepage = "https://tuned-project.org";
    changelog = "https://github.com/redhat-performance/tuned/releases/tag/v${finalAttrs.version}";
    license = lib.licenses.gpl2Only;
    maintainers = with lib.maintainers; [ getchoo ];
    platforms = lib.platforms.linux;
    mainProgram = "tuned";
  };
})
