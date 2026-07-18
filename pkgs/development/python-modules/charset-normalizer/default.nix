{
  lib,
  fetchFromGitHub,
  aiohttp,
  ast-serialize,
  buildPythonPackage,
  isPyPy,
  mypy,
  pytestCheckHook,
  requests,
  setuptools,
  withMypyc ? !isPyPy,
}:

buildPythonPackage rec {
  pname = "charset-normalizer";
  version = "3.4.7";

  src = fetchFromGitHub {
    owner = "jawah";
    repo = "charset_normalizer";
    tag = version;
    hash = "sha256-dOdJ4f98smCYdskp3BwtQG6aOyK+2a73+x580FKRWDk=";
  };

  postPatch = ''
    substituteInPlace _mypyc_hook/backend.py \
      --replace-fail "mypy>=1.4.1,<=1.20" "mypy"
  '';

  env.CHARSET_NORMALIZER_USE_MYPYC = lib.optionalString withMypyc "1";
  nativeCheckInputs = [ pytestCheckHook ];

  build-system = [
    setuptools
  ]
  ++ lib.optionals withMypyc [
    ast-serialize
    mypy
  ];

  pyproject = true;
  pythonImportsCheck = [ "charset_normalizer" ];

  passthru.tests = {
    inherit aiohttp requests;
  };

  meta = {
    description = "Python module for encoding and language detection";
    homepage = "https://charset-normalizer.readthedocs.io/";
    changelog = "https://github.com/jawah/charset_normalizer/blob/${src.tag}/CHANGELOG.md";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ fab ];
    mainProgram = "normalizer";
  };
}
