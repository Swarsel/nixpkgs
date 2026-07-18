{
  lib,
  buildPythonPackage,
  fetchFromBitbucket,
  pytestCheckHook,
  setuptools,
}:

buildPythonPackage rec {
  pname = "zcc-helper";
  version = "3.8";

  src = fetchFromBitbucket {
    owner = "mark_hannon";
    repo = "zcc";
    rev = "release_${version}";
    hash = "sha256-8jbDhlYIgmC0U6w9UY6PGvCnSDFiC/uBib08fikeabk=";
  };

  nativeCheckInputs = [
    pytestCheckHook
  ];

  build-system = [ setuptools ];
  pyproject = true;
  pythonImportsCheck = [ "zcc" ];

  meta = {
    description = "ZIMI ZCC helper module";
    homepage = "https://bitbucket.org/mark_hannon/zcc";
    changelog = "https://bitbucket.org/mark_hannon/zcc/src/${src.rev}/CHANGELOG.md";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ dotlambda ];
  };
}
