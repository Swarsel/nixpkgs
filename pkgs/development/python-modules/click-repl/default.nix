{
  lib,
  fetchFromGitHub,
  buildPythonPackage,
  # dependencies
  click,
  prompt-toolkit,
  # tests
  pytest-cov-stub,
  pytestCheckHook,
  # build-system
  setuptools,
  typing-extensions,
}:

buildPythonPackage (finalAttrs: {
  pname = "click-repl";
  version = "0.3.0-unstable-2026-03-26";

  src = fetchFromGitHub {
    owner = "click-contrib";
    repo = "click-repl";
    rev = "b84191aec21b407b3cb3374ff1ab000887d38f29";
    hash = "sha256-5Xv6oeV6sIRE3K3sZq8DyAXOcY8fYobcJtW/ZN7C4U0=";
  };

  nativeCheckInputs = [
    pytest-cov-stub
    pytestCheckHook
  ];

  build-system = [ setuptools ];

  dependencies = [
    click
    prompt-toolkit
    typing-extensions
  ];

  pyproject = true;

  meta = {
    description = "Subcommand REPL for click apps";
    homepage = "https://github.com/click-contrib/click-repl";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ twey ];
  };
})
