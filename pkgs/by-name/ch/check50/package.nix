{
  lib,
  fetchFromGitHub,
  python3Packages,
  versionCheckHook,
}:

python3Packages.buildPythonApplication (finalAttrs: {
  pname = "check50";
  version = "3.4.0";

  src = fetchFromGitHub {
    owner = "cs50";
    repo = "check50";
    tag = "v${finalAttrs.version}";
    hash = "sha256-3WxFdXECIjbTxHK65BFnxOroEYzu7iOJwm15gIjitLA=";
  };

  nativeCheckInputs = [ versionCheckHook ];

  build-system = [
    python3Packages.setuptools
  ];

  dependencies = with python3Packages; [
    attrs
    beautifulsoup4
    jinja2
    lib50
    packaging
    pexpect
    pyyaml
    requests
    setuptools # required for import pkg_resources
    termcolor
  ];

  pyproject = true;
  pythonImportsCheck = [ "check50" ];

  # no python tests
  meta = {
    description = "Testing tool for checking student CS50 code";
    homepage = "https://cs50.readthedocs.io/projects/check50/en/latest/";
    changelog = "https://github.com/cs50/check50/releases/tag/${finalAttrs.src.tag}";
    license = lib.licenses.gpl3Only;
    maintainers = with lib.maintainers; [ ethancedwards8 ];
    platforms = lib.platforms.unix;
    mainProgram = "check50";
    downloadPage = "https://github.com/cs50/check50";
  };
})
