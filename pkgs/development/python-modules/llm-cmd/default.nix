{
  lib,
  fetchFromGitHub,
  buildPythonPackage,
  llm,
  llm-cmd,
  # dependencies
  prompt-toolkit,
  pygments,
  # tests
  pytestCheckHook,
  # build-system
  setuptools,
}:

buildPythonPackage rec {
  pname = "llm-cmd";
  version = "0.2a0";

  src = fetchFromGitHub {
    owner = "simonw";
    repo = "llm-cmd";
    tag = version;
    hash = "sha256-RhwQEllpee/XP1p0nrgL4m+KjSZzf61J8l1jJGlg94E=";
  };

  # Only needed until https://github.com/simonw/llm-cmd/pull/18 is merged and released
  patches = [ ./fix-test.patch ];

  nativeCheckInputs = [
    pytestCheckHook
  ];

  build-system = [ setuptools ];

  dependencies = [
    llm
    prompt-toolkit
    pygments
  ];

  pyproject = true;

  pythonImportsCheck = [
    "llm_cmd"
  ];

  passthru.tests = llm.mkPluginTest llm-cmd;

  meta = {
    description = "Use LLM to generate and execute commands in your shell";
    homepage = "https://github.com/simonw/llm-cmd";
    changelog = "https://github.com/simonw/llm-cmd/releases/tag/${version}";
    license = lib.licenses.asl20;

    maintainers = with lib.maintainers; [
      erethon
      philiptaron
    ];
  };
}
