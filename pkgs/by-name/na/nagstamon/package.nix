{
  lib,
  fetchFromGitHub,
  python3Packages,
  qt6Packages,
}:

python3Packages.buildPythonApplication (finalAttrs: {
  pname = "nagstamon";
  version = "3.18.2";

  src = fetchFromGitHub {
    owner = "HenriWahl";
    repo = "Nagstamon";
    tag = "v${finalAttrs.version}";
    hash = "sha256-ZA6gxV9zLKZ0g5v8CvnAuiYPhEDByz17kC54Idk9CYM=";
  };

  nativeBuildInputs = [ qt6Packages.wrapQtAppsHook ];

  buildInputs = [
    qt6Packages.qtmultimedia
    qt6Packages.qtsvg
  ];

  nativeCheckInputs = with python3Packages; [
    pylint
    pytestCheckHook
  ];

  preFixup = ''
    makeWrapperArgs+=("''${qtWrapperArgs[@]}")
  '';

  __structuredAttrs = true;
  build-system = with python3Packages; [ setuptools ];

  dependencies = with python3Packages; [
    arrow
    beautifulsoup4
    configparser
    dbus-python
    keyring
    lxml
    packaging
    psutil
    pyqt6
    pyqt6-webengine
    pysocks
    python-dateutil
    requests
    requests-kerberos
    setuptools
    tzlocal
  ];

  dontWrapQtApps = true;
  pyproject = true;

  meta = {
    description = "Status monitor for the desktop";
    homepage = "https://nagstamon.de/";
    changelog = "https://github.com/HenriWahl/Nagstamon/releases/tag/v${finalAttrs.version}";
    license = lib.licenses.gpl2Plus;

    maintainers = with lib.maintainers; [
      pSub
      liberodark
      videl
    ];

    # NameError: name 'bdist_rpm_options' is not defined. Did you mean: 'bdist_mac_options'?
    badPlatforms = [ lib.systems.inspect.patterns.isDarwin ];
    mainProgram = "nagstamon.py";
  };
})
