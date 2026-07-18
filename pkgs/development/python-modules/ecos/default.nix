{
  lib,
  fetchFromGitHub,
  buildPythonPackage,
  oldest-supported-numpy,
  pytestCheckHook,
  scipy,
  setuptools,
}:

buildPythonPackage rec {
  pname = "ecos";
  version = "2.0.14";

  src = fetchFromGitHub {
    owner = "embotech";
    repo = "ecos-python";
    tag = "v${version}";
    hash = "sha256-nfu1FicWr233r+VHxkQf1vqh2y4DGymJRmik8RJYJkA=";
    fetchSubmodules = true;
  };

  postPatch = ''
    substituteInPlace pyproject.toml \
      --replace-fail "numpy >= 2.0.0" numpy
  '';

  nativeCheckInputs = [ pytestCheckHook ];
  build-system = [ setuptools ];

  dependencies = [
    oldest-supported-numpy
    scipy
  ];

  pyproject = true;
  pythonImportsCheck = [ "ecos" ];

  meta = {
    description = "Python interface for ECOS";
    homepage = "https://github.com/embotech/ecos-python";
    changelog = "https://github.com/embotech/ecos-python/releases/tag/v${version}";
    license = lib.licenses.gpl3Only;
    maintainers = [ ];
  };
}
