{
  lib,
  fetchFromGitHub,
  buildPythonPackage,
  pytestCheckHook,
  setuptools,
}:

buildPythonPackage (finalAttrs: {
  pname = "shellescape";
  version = "3.8.1";

  src = fetchFromGitHub {
    owner = "chrissimpkins";
    repo = "shellescape";
    tag = "v${finalAttrs.version}";
    hash = "sha256-HAe3Qf3lLeVWw/tVkW0J+CfoxSoOnCcWDR2nEWZn7HM=";
  };

  nativeCheckInputs = [ pytestCheckHook ];
  __structuredAttrs = true;
  build-system = [ setuptools ];
  pyproject = true;
  pythonImportsCheck = [ "shellescape" ];

  meta = {
    description = "Shell escape a string to safely use it as a token in a shell command (backport of Python shlex.quote)";
    homepage = "https://github.com/chrissimpkins/shellescape";

    license = with lib.licenses; [
      mit
      psfl
    ];

    maintainers = with lib.maintainers; [ veprbl ];
  };
})
