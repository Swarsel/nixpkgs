{
  lib,
  fetchFromGitHub,
  buildPythonPackage,
  colcon,
  pytest-cov-stub,
  pytest-repeat,
  pytest-rerunfailures,
  pytestCheckHook,
  scspell,
  setuptools,
  writableTmpDirAsHomeHook,
}:
buildPythonPackage (finalAttrs: {
  pname = "colcon-ros-domain-id-coordinator";
  version = "0.2.4";

  src = fetchFromGitHub {
    owner = "colcon";
    repo = "colcon-ros-domain-id-coordinator";
    tag = finalAttrs.version;
    hash = "sha256-B7BBBng/fODqVtneVgjoPgU6Cyon66PQa2QcGuRLfFU=";
  };

  nativeCheckInputs = [
    pytestCheckHook
    pytest-cov-stub
    pytest-repeat
    pytest-rerunfailures
    scspell
    writableTmpDirAsHomeHook
  ];

  build-system = [ setuptools ];

  dependencies = [
    colcon
  ];

  disabledTestPaths = [
    "test/test_flake8.py"
  ];

  pyproject = true;

  pythonImportsCheck = [
    "colcon_ros_domain_id_coordinator"
  ];

  meta = {
    description = "Extension for colcon-core to coordinate ROS_DOMAIN_ID values across multiple terminals";
    homepage = "https://github.com/colcon/colcon-ros-domain-id-coordinator";
    license = lib.licenses.asl20;
    maintainers = with lib.maintainers; [ guelakais ];
  };
})
