{
  lib,
  fetchFromGitHub,
  buildPythonPackage,
  dataclasses-json,
  pytest-xdist,
  pytestCheckHook,
  requests,
  requests-mock,
  setuptools,
  setuptools-scm,
  syrupy,
}:

buildPythonPackage rec {
  pname = "pyecotrend-ista";
  version = "3.5.0";

  src = fetchFromGitHub {
    owner = "Ludy87";
    repo = "pyecotrend-ista";
    tag = version;
    hash = "sha256-O5HU0U19E+cS1/UVYouxbyTBNjenJw9kkH80GCZ04cw=";
  };

  postPatch = ''
    sed -i "/addopts =/d" pyproject.toml
  '';

  nativeCheckInputs = [
    pytestCheckHook
    pytest-xdist
    requests-mock
    syrupy
  ];

  build-system = [
    setuptools
    setuptools-scm
  ];

  dependencies = [
    dataclasses-json
    requests
  ];

  pyproject = true;
  pythonImportsCheck = [ "pyecotrend_ista" ];

  meta = {
    description = "Unofficial python library for the pyecotrend-ista API";
    homepage = "https://github.com/Ludy87/pyecotrend-ista";
    changelog = "https://github.com/Ludy87/pyecotrend-ista/releases/tag/${version}";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ oynqr ];
  };
}
