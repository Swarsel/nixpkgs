{
  lib,
  fetchFromGitHub,
  buildPythonPackage,
  cython,
  freesasa,
  pytestCheckHook,
  setuptools,
}:

buildPythonPackage rec {
  pname = "freesasa";
  version = "2.2.1";

  src = fetchFromGitHub {
    owner = "freesasa";
    repo = "freesasa-python";
    tag = "v${version}";
    hash = "sha256-/7ymItwXOemY0+IL0k6rWnJI8fAwTFjNXzTV+uf9x9A=";
  };

  postPatch = ''
    ln -s ${freesasa.src}/* lib/
  '';

  env.USE_CYTHON = true;
  nativeCheckInputs = [ pytestCheckHook ];

  build-system = [
    cython
    setuptools
  ];

  enabledTestPaths = [ "test.py" ];
  pyproject = true;
  pythonImportsCheck = [ "freesasa" ];

  meta = {
    description = "FreeSASA Python Module";
    homepage = "https://github.com/freesasa/freesasa-python";
    changelog = "https://github.com/freesasa/freesasa-python/blob/${src.rev}/CHANGELOG.md";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ natsukium ];
  };
}
