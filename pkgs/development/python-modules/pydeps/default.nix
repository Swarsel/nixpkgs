{
  lib,
  fetchFromGitHub,
  buildPythonPackage,
  graphviz,
  pytestCheckHook,
  pyyaml,
  setuptools,
  stdlib-list,
  toml,
}:

buildPythonPackage (finalAttrs: {
  pname = "pydeps";
  version = "3.0.6";

  src = fetchFromGitHub {
    owner = "thebjorn";
    repo = "pydeps";
    tag = "v${finalAttrs.version}";
    hash = "sha256-/Ie75jQWG3t4cGMRMVPJ7r6aBdm4hC7/CgwmuOUk4BA=";
  };

  postPatch = ''
    # Path is hard-coded
    substituteInPlace pydeps/dot.py \
      --replace "dot -Gstart=1" "${lib.makeBinPath [ graphviz ]}/dot -Gstart=1"
  '';

  buildInputs = [ graphviz ];

  nativeCheckInputs = [
    pytestCheckHook
    pyyaml
    toml
  ];

  build-system = [ setuptools ];

  dependencies = [
    graphviz
    stdlib-list
  ];

  disabledTests = [
    # Would require to have additional modules available
    "test_find_package_names"
  ];

  pyproject = true;
  pythonImportsCheck = [ "pydeps" ];

  meta = {
    description = "Python module dependency visualization";
    homepage = "https://github.com/thebjorn/pydeps";
    changelog = "https://github.com/thebjorn/pydeps/releases/tag/${finalAttrs.src.tag}";
    license = lib.licenses.bsd2;
    maintainers = with lib.maintainers; [ fab ];
    mainProgram = "pydeps";
  };
})
