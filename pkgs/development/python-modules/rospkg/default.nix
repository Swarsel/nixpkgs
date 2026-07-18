{
  lib,
  fetchFromGitHub,
  buildPythonPackage,
  catkin-pkg,
  distro,
  distutils,
  pytestCheckHook,
  pyyaml,
  setuptools,
}:

buildPythonPackage rec {
  pname = "rospkg";
  version = "1.6.1";

  src = fetchFromGitHub {
    owner = "ros-infrastructure";
    repo = "rospkg";
    tag = version;
    hash = "sha256-YRBmL+aXQ/0rxivERja9ng+GqL8NQGmNYhKjMY7+6nc=";
  };

  nativeCheckInputs = [
    pytestCheckHook
  ];

  build-system = [ setuptools ];

  dependencies = [
    catkin-pkg
    distro
    distutils
    pyyaml
  ];

  pyproject = true;
  pythonImportsCheck = [ "rospkg" ];
  setupHook = ./setup-hook.sh;

  meta = {
    description = "ROS package library for Python";
    homepage = "http://wiki.ros.org/rospkg";
    changelog = "https://github.com/ros-infrastructure/rospkg/blob/${version}/CHANGELOG.rst";
    license = lib.licenses.bsd3;
    maintainers = with lib.maintainers; [ guelakais ];
  };
}
