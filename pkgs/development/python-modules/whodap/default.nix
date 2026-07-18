{
  lib,
  fetchFromGitHub,
  buildPythonPackage,
  httpx,
  pytest-asyncio,
  pytestCheckHook,
  setuptools,
}:

buildPythonPackage (finalAttrs: {
  pname = "whodap";
  version = "0.1.16";

  src = fetchFromGitHub {
    owner = "pogzyb";
    repo = "whodap";
    tag = "v${finalAttrs.version}";
    hash = "sha256-ybJiAWrAcs/9/8WutqsHvwsiWxR+tJL9wcQRaOiUZNQ=";
  };

  postPatch = ''
    substituteInPlace pyproject.toml \
      --replace-fail "setuptools==82.0.1" "setuptools" \
      --replace-fail "wheel==0.46.3" "wheel"
  '';

  nativeCheckInputs = [
    pytest-asyncio
    pytestCheckHook
  ];

  build-system = [ setuptools ];
  dependencies = [ httpx ];

  disabledTestPaths = [
    # Requires network access
    "tests/test_client.py"
  ];

  pyproject = true;
  pythonImportsCheck = [ "whodap" ];

  meta = {
    description = "Python RDAP utility for querying and parsing information about domain names";
    homepage = "https://github.com/pogzyb/whodap";
    changelog = "https://github.com/pogzyb/whodap/releases/tag/${finalAttrs.src.tag}";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ fab ];
  };
})
