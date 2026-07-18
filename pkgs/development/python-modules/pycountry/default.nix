{
  lib,
  fetchFromGitHub,
  buildPythonPackage,
  poetry-core,
  pytestCheckHook,
}:

buildPythonPackage rec {
  pname = "pycountry";
  version = "26.2.16";

  src = fetchFromGitHub {
    owner = "pycountry";
    repo = "pycountry";
    tag = version;
    hash = "sha256-VmPCQszEaDNsSnMfAo5xyDZySJcC4TiWZrmQMfebKKQ=";
  };

  postPatch = ''
    sed -i "/addopts/d" pyproject.toml
    sed -i "/pytest-cov/d" pyproject.toml
  '';

  nativeCheckInputs = [ pytestCheckHook ];
  build-system = [ poetry-core ];
  pyproject = true;
  pythonImportsCheck = [ "pycountry" ];

  meta = {
    description = "ISO country, subdivision, language, currency and script definitions and their translations";
    homepage = "https://github.com/pycountry/pycountry";
    changelog = "https://github.com/pycountry/pycountry/blob/${src.tag}/HISTORY.txt";
    license = lib.licenses.lgpl21Plus;
    maintainers = with lib.maintainers; [ dotlambda ];
  };
}
