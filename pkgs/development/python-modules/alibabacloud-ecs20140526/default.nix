{
  lib,
  alibabacloud-tea-openapi,
  buildPythonPackage,
  darabonba-core,
  fetchPypi,
  setuptools,
}:

buildPythonPackage (finalAttrs: {
  pname = "alibabacloud-ecs20140526";
  version = "7.9.1";

  src = fetchPypi {
    inherit (finalAttrs) version;
    hash = "sha256-ntrWxB3W/fR4RBGrX4I+fcyJScCri+9V9RxAZbJQeHE=";
    pname = "alibabacloud_ecs20140526";
  };

  # Module has no tests
  doCheck = false;
  __structuredAttrs = true;
  build-system = [ setuptools ];

  dependencies = [
    alibabacloud-tea-openapi
    darabonba-core
  ];

  pyproject = true;
  pythonImportsCheck = [ "alibabacloud_ecs20140526" ];

  meta = {
    description = "Alibaba Cloud Elastic Compute Service (20140526) SDK Library for Python";
    homepage = "https://pypi.org/project/alibabacloud-ecs20140526/";
    license = lib.licenses.asl20;
    maintainers = with lib.maintainers; [ fab ];
  };
})
