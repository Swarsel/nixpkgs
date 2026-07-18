{
  lib,
  alibabacloud-tea-openapi,
  buildPythonPackage,
  darabonba-core,
  fetchPypi,
  nix-update-script,
  setuptools,
}:

buildPythonPackage (finalAttrs: {
  pname = "alibabacloud-actiontrail20200706";
  version = "2.6.0";

  src = fetchPypi {
    inherit (finalAttrs) version;
    hash = "sha256-+vsUsjOZPaV8+GjmSQMGu62hmuNLDRcCvJo52WFNAVc=";
    pname = "alibabacloud_actiontrail20200706";
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
  pythonImportsCheck = [ "alibabacloud_actiontrail20200706" ];
  passthru.updateScript = nix-update-script { };

  meta = {
    description = "Alibaba Cloud ActionTrail (20200706) SDK Library for Python";
    homepage = "https://pypi.org/project/alibabacloud-actiontrail20200706/";
    license = lib.licenses.asl20;
    maintainers = with lib.maintainers; [ fab ];
  };
})
