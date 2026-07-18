{
  lib,
  fetchFromGitHub,
  buildPythonPackage,
  hatchling,
  pytestCheckHook,
  pythonAtLeast,
  requests,
  typing-extensions,
}:

buildPythonPackage rec {
  pname = "python-picnic-api2";
  version = "1.3.4";

  src = fetchFromGitHub {
    owner = "codesalatdev";
    repo = "python-picnic-api";
    tag = "v${version}";
    hash = "sha256-ytzzGr/z0jrsudtCBrcvGITo4DxxC8JCmSmQ8ybeomM=";
  };

  postPatch = lib.optionalString (pythonAtLeast "3.14") ''
    substituteInPlace tests/test_session.py \
      --replace-fail '"Accept-Encoding": "gzip, deflate",' '"Accept-Encoding": "gzip, deflate, zstd",'
  '';

  nativeCheckInputs = [ pytestCheckHook ];
  build-system = [ hatchling ];

  dependencies = [
    requests
    typing-extensions
  ];

  disabledTestPaths = [
    # tests access the actual API
    "integration_tests"
  ];

  pyproject = true;
  pythonImportsCheck = [ "python_picnic_api2" ];

  meta = {
    description = "Fork of the Unofficial Python wrapper for the Picnic API";
    homepage = "https://github.com/codesalatdev/python-picnic-api";
    changelog = "https://github.com/codesalatdev/python-picnic-api/releases/tag/${src.tag}";
    license = lib.licenses.asl20;
    maintainers = with lib.maintainers; [ dotlambda ];
  };
}
