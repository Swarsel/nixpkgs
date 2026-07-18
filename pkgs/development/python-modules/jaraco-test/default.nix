{
  lib,
  fetchFromGitHub,
  buildPythonPackage,
  jaraco-collections,
  jaraco-context,
  jaraco-functools,
  pytest8_3CheckHook,
  setuptools-scm,
}:

buildPythonPackage rec {
  pname = "jaraco-test";
  version = "5.6.0";

  src = fetchFromGitHub {
    owner = "jaraco";
    repo = "jaraco.test";
    tag = "v${version}";
    hash = "sha256-Ym0r92xCh+DNpFexqPlRVgcDGYNvnaJHEs5/RMaUr+s=";
  };

  postPatch = ''
    substituteInPlace pyproject.toml \
      --replace-fail '"coherent.licensed",' ""
  '';

  nativeCheckInputs = [ pytest8_3CheckHook ];
  build-system = [ setuptools-scm ];

  dependencies = [
    jaraco-functools
    jaraco-context
    jaraco-collections
  ];

  pyproject = true;
  pythonImportsCheck = [ "jaraco.test" ];

  meta = {
    description = "Testing support by jaraco";
    homepage = "https://github.com/jaraco/jaraco.test";
    changelog = "https://github.com/jaraco/jaraco.test/blob/${src.tag}/NEWS.rst";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ dotlambda ];
  };
}
