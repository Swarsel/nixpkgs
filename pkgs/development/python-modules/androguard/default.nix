{
  lib,
  fetchFromGitHub,
  apkinspector,
  asn1crypto,
  buildPythonPackage,
  click,
  colorama,
  cryptography,
  dataset,
  frida-python,
  ipython,
  loguru,
  lxml,
  matplotlib,
  mutf8,
  networkx,
  oscrypto,
  poetry-core,
  pydot,
  pygments,
  pyqt5,
  pytestCheckHook,
  python-magic,
  pyyaml,
  qt5,
  # Deprecated in 24.11.
  doCheck ? true,
  # This is usually used as a library, and it'd be a shame to force the GUI
  # libraries to the closure if GUI is not desired.
  withGui ? false,
}:

assert lib.warnIf (!doCheck) "python3Packages.androguard: doCheck is deprecated" true;

buildPythonPackage rec {
  pname = "androguard";
  version = "4.1.3";

  src = fetchFromGitHub {
    owner = "androguard";
    repo = "androguard";
    tag = "v${version}";
    sha256 = "sha256-qz6x7UgYXal1DbQGzi4iKnSGEn873rKibKme/pF7tLk=";
  };

  nativeBuildInputs = lib.optionals withGui [ qt5.wrapQtAppsHook ];

  nativeCheckInputs = [
    pytestCheckHook
    pyqt5
    python-magic
  ];

  preFixup = lib.optionalString withGui ''
    makeWrapperArgs+=("''${qtWrapperArgs[@]}")
  '';

  build-system = [
    poetry-core
  ];

  dependencies = [
    apkinspector
    asn1crypto
    click
    colorama
    cryptography
    dataset
    frida-python
    ipython
    loguru
    lxml
    matplotlib
    mutf8
    networkx
    oscrypto
    pydot
    pygments
    pyyaml
  ]
  ++ networkx.optional-dependencies.default
  ++ networkx.optional-dependencies.extra
  ++ lib.optionals withGui [
    pyqt5
  ];

  pyproject = true;
  # If it won't be verbose, you'll see nothing going on for a long time.
  pytestFlags = [ "--verbose" ];

  meta = {
    description = "Tool and Python library to interact with Android Files";
    homepage = "https://github.com/androguard/androguard";
    license = lib.licenses.asl20;
    maintainers = with lib.maintainers; [ pmiddend ];
  };
}
