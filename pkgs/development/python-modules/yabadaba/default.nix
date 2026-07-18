{
  lib,
  fetchFromGitHub,
  buildPythonPackage,
  # dependencies
  cdcs,
  datamodeldict,
  ipython,
  lxml,
  numpy,
  pandas,
  pillow,
  pymongo,
  # tests
  pytestCheckHook,
  # build-system
  setuptools,
  tqdm,
  writableTmpDirAsHomeHook,
}:

buildPythonPackage rec {
  pname = "yabadaba";
  version = "0.3.2";

  src = fetchFromGitHub {
    owner = "usnistgov";
    repo = "yabadaba";
    tag = "v${version}";
    hash = "sha256-ZVV/2/RyDj707OEWcwFgQjJImgoiv91ZEutT3RBuWus=";
  };

  nativeCheckInputs = [
    pytestCheckHook
    writableTmpDirAsHomeHook
  ];

  build-system = [ setuptools ];

  dependencies = [
    cdcs
    datamodeldict
    ipython
    lxml
    numpy
    pandas
    pillow
    pymongo
    tqdm
  ];

  pyproject = true;
  pythonImportsCheck = [ "yabadaba" ];

  meta = {
    description = "Abstraction layer allowing for common interactions with databases and records";
    homepage = "https://github.com/usnistgov/yabadaba";
    changelog = "https://github.com/usnistgov/yabadaba/releases/tag/v${version}";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ fab ];
  };
}
