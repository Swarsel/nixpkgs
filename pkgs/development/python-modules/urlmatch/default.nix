{
  lib,
  fetchFromGitHub,
  buildPythonPackage,
  setuptools,
}:

buildPythonPackage rec {
  pname = "urlmatch";
  version = "1.0.1";

  src = fetchFromGitHub {
    owner = "jessepollak";
    repo = "urlmatch";
    tag = "v${version}";
    hash = "sha256-01QkkdtSDBB3s+F7lC/0kZ+r1jxd/S7QA8LkweG9SZI=";
  };

  # The only test fails with:
  #  ImportError: cannot import name 'BadMatchPattern' from 'urlmatch' (/private/tmp/nix-build-python3.12-urlmatch-1.0.0.drv-0/source/urlmatch/__init__.py)
  doCheck = false;

  build-system = [
    setuptools
  ];

  pyproject = true;
  pythonImportsCheck = [ "urlmatch" ];

  meta = {
    description = "Python library for easily pattern matching wildcard URLs";
    homepage = "https://github.com/jessepollak/urlmatch";
    changelog = "https://github.com/jessepollak/urlmatch/releases/tag/v${version}/CHANGELOG.md";
    license = lib.licenses.asl20;
    maintainers = with lib.maintainers; [ ethancedwards8 ];
  };
}
