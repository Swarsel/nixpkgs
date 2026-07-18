{
  lib,
  fetchFromGitHub,
  attrs,
  buildPythonPackage,
  click,
  ldfparser,
  lxml,
  openpyxl,
  pytest-cov-stub,
  pytest-timeout,
  pytestCheckHook,
  pyyaml,
  setuptools,
  xlrd,
  xlwt,
}:

buildPythonPackage rec {
  pname = "canmatrix";
  version = "1.2";

  src = fetchFromGitHub {
    owner = "ebroecker";
    repo = "canmatrix";
    tag = version;
    hash = "sha256-PfegsFha7ernSqnMeaDoLf1jLx1CiOoiYi34dESEgBY=";
  };

  nativeCheckInputs = [
    pytest-cov-stub
    pytest-timeout
    pytestCheckHook
  ]
  ++ lib.concatAttrValues optional-dependencies;

  build-system = [ setuptools ];

  dependencies = [
    attrs
    click
  ];

  disabledTests = [ "long_envvar_name_imports" ];

  enabledTestPaths = [
    "src/canmatrix"
    "tests/"
  ];

  optional-dependencies = {
    arxml = [ lxml ];
    fibex = [ lxml ];
    kcd = [ lxml ];
    ldf = [ ldfparser ];
    odx = [ lxml ];

    xls = [
      xlrd
      xlwt
    ];

    xlsx = [ openpyxl ];
    yaml = [ pyyaml ];
  };

  pyproject = true;

  pytestFlags = [
    # long_envvar_name_imports requires stable key value pair ordering
    "-s"
  ];

  pythonImportsCheck = [ "canmatrix" ];

  meta = {
    description = "Support and convert several CAN (Controller Area Network) database formats";
    homepage = "https://github.com/ebroecker/canmatrix";
    changelog = "https://github.com/ebroecker/canmatrix/releases/tag/${version}";
    license = lib.licenses.bsd2;
    maintainers = with lib.maintainers; [ sorki ];
  };
}
