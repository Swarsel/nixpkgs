{
  lib,
  fetchFromGitHub,
  buildPythonPackage,
  e3-core,
  setuptools,
}:

buildPythonPackage rec {
  pname = "e3-testsuite";
  version = "27.2";

  src = fetchFromGitHub {
    owner = "AdaCore";
    repo = "e3-testsuite";
    tag = "v${version}";
    hash = "sha256-qG8SHwogBle3demgFJCqcfCh5ktLvOqh2XSwxPCANFk=";
  };

  build-system = [ setuptools ];
  dependencies = [ e3-core ];
  pyproject = true;
  pythonImportsCheck = [ "e3" ];

  meta = {
    description = "Generic testsuite framework in Python";
    homepage = "https://github.com/AdaCore/e3-testsuite/";
    changelog = "https://github.com/AdaCore/e3-testsuite/releases/tag/${src.tag}";
    license = lib.licenses.gpl3Only;
    maintainers = with lib.maintainers; [ heijligen ];
    platforms = lib.platforms.linux;
  };
}
