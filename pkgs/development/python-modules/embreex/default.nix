{
  lib,
  fetchFromGitHub,
  buildPythonPackage,
  cython,
  embree,
  fetchpatch,
  numpy,
  pytestCheckHook,
  setuptools,
}:

buildPythonPackage rec {
  pname = "embreex";
  version = "4.4.0";

  src = fetchFromGitHub {
    owner = "trimesh";
    repo = "embreex";
    tag = version;
    hash = "sha256-mUPc9CMHsFYb1ELBmj+XXCjYEIW1iV8ZaRCQ40tYS8w=";
  };

  buildInputs = [
    embree
  ];

  nativeCheckInputs = [ pytestCheckHook ];

  preCheck = ''
    # conflicts with $out
    rm -rf embreex/
  '';

  build-system = [
    setuptools
    numpy
    cython
  ];

  dependencies = [
    numpy
  ];

  pyproject = true;

  pythonImportsCheck = [
    "embreex"
    "embreex.mesh_construction"
    "embreex.rtcore"
    "embreex.rtcore_scene"
  ];

  meta = {
    inherit (embree.meta) platforms;
    description = "Maintained PyEmbree fork, bindings for Intel's Embree ray engine";
    homepage = "https://github.com/trimesh/embreex";
    changelog = "https://github.com/trimesh/embreex/releases/tag/${src.tag}";
    license = lib.licenses.bsd2;
    maintainers = with lib.maintainers; [ pbsds ];
  };
}
