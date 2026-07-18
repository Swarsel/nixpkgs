{
  lib,
  fetchFromGitHub,
  buildPythonPackage,
  pillow,
  pytestCheckHook,
  requests,
  setuptools,
  urwid,
}:

buildPythonPackage rec {
  pname = "term-image";
  version = "0.7.2";

  src = fetchFromGitHub {
    owner = "AnonymouX47";
    repo = "term-image";
    tag = "v${version}";
    hash = "sha256-uA04KHKLXW0lx1y5brpCDARLac4/C8VmVinVMkEtTdM=";
  };

  # Override the overly strict `tool.pytest.ini_options.filterwarnings`
  postPatch = ''
    substituteInPlace pyproject.toml \
      --replace-fail '"error"' '#"error"'
  '';

  nativeCheckInputs = [
    pytestCheckHook
  ]
  ++ optional-dependencies.urwid;

  build-system = [
    setuptools
  ];

  dependencies = [
    requests
    pillow
  ];

  disabledTestPaths = [
    # test_url needs online access
    "tests/test_image/test_url.py"
  ];

  optional-dependencies = {
    urwid = [ urwid ];
  };

  pyproject = true;
  pythonImportsCheck = [ "term_image" ];
  pythonRelaxDeps = [ "pillow" ];

  meta = {
    description = "Display images in the terminal with python";
    homepage = "https://github.com/AnonymouX47/term-image";
    changelog = "https://github.com/AnonymouX47/term-image/releases/tag/v${version}";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ liff ];
  };
}
