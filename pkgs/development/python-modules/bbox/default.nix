{
  lib,
  fetchFromGitHub,
  buildPythonPackage,
  matplotlib,
  numpy,
  pendulum,
  pillow,
  poetry-core,
  pyquaternion,
  pytestCheckHook,
}:

buildPythonPackage {
  pname = "bbox";
  version = "0.9.4";

  src = fetchFromGitHub {
    owner = "varunagrawal";
    repo = "bbox";
    # matches 0.9.4 on PyPi + tests
    rev = "d3f07ed0e38b6015cf4181e3b3edae6a263f8565";
    hash = "sha256-FrJ8FhlqwmnEB/QvPlkDfqZncNGPhwY9aagM9yv1LGs=";
  };

  postPatch = ''
    substituteInPlace bbox/metrics.py \
      --replace-warn round_ round
  '';

  nativeBuildInputs = [ poetry-core ];

  propagatedBuildInputs = [
    pyquaternion
    numpy
  ];

  nativeCheckInputs = [
    matplotlib
    pendulum
    pillow
    pytestCheckHook
  ];

  disabledTests = [
    # performance test, racy on busy machines
    "test_multi_jaccard_index_2d_performance"
  ];

  pyproject = true;
  pythonImportsCheck = [ "bbox" ];
  pythonRelaxDeps = [ "numpy" ];

  meta = {
    description = "Python library for 2D/3D bounding boxes";
    homepage = "https://github.com/varunagrawal/bbox";
    license = lib.licenses.mit;
    maintainers = [ ];
  };
}
