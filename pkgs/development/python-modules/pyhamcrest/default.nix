{
  lib,
  fetchFromGitHub,
  buildPythonPackage,
  hatch-vcs,
  hatchling,
  numpy,
  pytest-xdist,
  pytestCheckHook,
}:

buildPythonPackage rec {
  pname = "pyhamcrest";
  version = "2.1.0";

  src = fetchFromGitHub {
    owner = "hamcrest";
    repo = "PyHamcrest";
    tag = "V${version}";
    hash = "sha256-VkfHRo4k8g9/QYG4r79fXf1NXorVdpUKUgVrbV2ELMU=";
  };

  patches = [
    # https://github.com/hamcrest/PyHamcrest/pull/270
    ./python314-compat.patch
  ];

  postPatch = ''
    substituteInPlace pyproject.toml \
      --replace 'dynamic = ["version"]' 'version = "${version}"'
  '';

  nativeCheckInputs = [
    numpy
    pytest-xdist
    pytestCheckHook
  ];

  build-system = [
    hatch-vcs
    hatchling
  ];

  disabledTests = [
    # Tests started failing with numpy 1.24
    "test_numpy_numeric_type_complex"
    "test_numpy_numeric_type_float"
    "test_numpy_numeric_type_int"
  ];

  pyproject = true;
  pythonImportsCheck = [ "hamcrest" ];

  meta = {
    description = "Hamcrest framework for matcher objects";
    homepage = "https://github.com/hamcrest/PyHamcrest";
    license = lib.licenses.bsd3;
    maintainers = with lib.maintainers; [ alunduil ];
  };
}
