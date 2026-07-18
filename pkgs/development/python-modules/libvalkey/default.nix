{
  lib,
  fetchFromGitHub,
  buildPythonPackage,
  pytestCheckHook,
  setuptools,
}:

buildPythonPackage (finalAttrs: {
  pname = "libvalkey-py";
  version = "4.0.1";

  src = fetchFromGitHub {
    owner = "valkey-io";
    repo = "libvalkey-py";
    tag = "v${finalAttrs.version}";
    hash = "sha256-tOq4SC9xA1rXfclqIzseedu7lyQ+7ZcVy/4ELTAorJ4=";
    fetchSubmodules = true;
  };

  nativeCheckInputs = [
    pytestCheckHook
  ];

  preCheck = ''
    # import from $out
    rm -r libvalkey
  '';

  build-system = [ setuptools ];
  pyproject = true;
  pythonImportsCheck = [ "libvalkey" ];

  meta = {
    description = "Python wrapper for libvalkey";
    homepage = "https://github.com/valkey-io/libvalkey-py";
    changelog = "https://github.com/valkey-io/libvalkey-py/blob/${finalAttrs.src.tag}/CHANGELOG.md";
    license = lib.licenses.mit;
    maintainers = [ lib.maintainers.dotlambda ];
  };
})
