{
  lib,
  fetchFromGitHub,
  buildPythonPackage,
  pytestCheckHook,
  pythonAtLeast,
  setuptools,
}:

buildPythonPackage rec {
  pname = "dacite";
  version = "1.9.2";

  src = fetchFromGitHub {
    owner = "konradhalas";
    repo = "dacite";
    tag = "v${version}";
    hash = "sha256-mAPqWvBpkTbtzHpwtCSDXMNkoc8/hbRH3OIEeK2yStU=";
  };

  postPatch = ''
    substituteInPlace pyproject.toml \
      --replace "--benchmark-autosave --benchmark-json=benchmark.json" ""
  ''
  + lib.optionalString (pythonAtLeast "3.14") ''
    substituteInPlace tests/core/test_union.py \
      --replace-fail "typing.Union[int, str]" "int | str"
  '';

  nativeCheckInputs = [ pytestCheckHook ];
  build-system = [ setuptools ];
  disabledTestPaths = [ "tests/performance" ];
  pyproject = true;
  pythonImportsCheck = [ "dacite" ];

  meta = {
    description = "Python helper to create data classes from dictionaries";
    homepage = "https://github.com/konradhalas/dacite";
    changelog = "https://github.com/konradhalas/dacite/blob/v${version}/CHANGELOG.md";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ fab ];
  };
}
