{
  lib,
  fetchFromGitHub,
  appdirs,
  argcomplete,
  buildPythonPackage,
  hypothesis,
  importlib-resources,
  jaconv,
  mock,
  pillow,
  pycups,
  pyserial,
  pytest-cov-stub,
  pytest-mock,
  pytestCheckHook,
  python-barcode,
  pyusb,
  pyyaml,
  qrcode,
  scripttest,
  setuptools,
  setuptools-scm,
  six,
}:

buildPythonPackage (finalAttrs: {
  pname = "python-escpos";
  version = "3.1";

  src = fetchFromGitHub {
    owner = "python-escpos";
    repo = "python-escpos";
    tag = "v${finalAttrs.version}";
    hash = "sha256-f7qA1+8PwnXS526jjULEoyn0ejnvsneuWDt863p4J2g=";
    fetchSubmodules = true;
  };

  nativeCheckInputs = [
    jaconv
    pytestCheckHook
    pytest-cov-stub
    pytest-mock
    scripttest
    mock
    hypothesis
  ]
  ++ finalAttrs.passthru.optional-dependencies.all;

  preCheck = ''
    # force the tests to use the module in $out
    rm -r src

    # allow tests to find the cli executable
    export PATH="$out/bin:$PATH"
  '';

  build-system = [
    setuptools
    setuptools-scm
  ];

  dependencies = [
    pillow
    qrcode
    python-barcode
    six
    appdirs
    pyyaml
    argcomplete
    importlib-resources
  ];

  optional-dependencies = {
    all = [
      pyusb
      pyserial
      pycups
    ];

    cups = [ pycups ];
    serial = [ pyserial ];
    usb = [ pyusb ];
  };

  pyproject = true;
  pythonImportsCheck = [ "escpos" ];

  meta = {
    description = "Python library to manipulate ESC/POS printers";
    homepage = "https://python-escpos.readthedocs.io/";
    changelog = "https://github.com/python-escpos/python-escpos/blob/${finalAttrs.src.rev}/CHANGELOG.rst";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ tomasajt ];
    mainProgram = "python-escpos";
  };
})
