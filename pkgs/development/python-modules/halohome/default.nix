{
  lib,
  fetchFromGitHub,
  aiohttp,
  bleak,
  buildPythonPackage,
  csrmesh,
  setuptools,
}:

buildPythonPackage rec {
  pname = "halohome";
  version = "0.7.0";

  src = fetchFromGitHub {
    owner = "nayaverdier";
    repo = "halohome";
    tag = version;
    hash = "sha256-JOQ2q5lbdVTerXPt6QHBiTG9PzN9LiuLcN+XnOoyYjA=";
  };

  # Project has no tests
  doCheck = false;
  build-system = [ setuptools ];

  dependencies = [
    aiohttp
    bleak
    csrmesh
  ];

  pyproject = true;
  pythonImportsCheck = [ "halohome" ];
  pythonRelaxDeps = [ "bleak" ];

  meta = {
    description = "Python library to control Eaton HALO Home Smart Lights";
    homepage = "https://github.com/nayaverdier/halohome";
    changelog = "https://github.com/nayaverdier/halohome/blob/${version}/CHANGELOG.md";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ fab ];
  };
}
