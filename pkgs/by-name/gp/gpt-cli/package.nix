{
  lib,
  fetchFromGitHub,
  python3Packages,
  versionCheckHook,
}:

python3Packages.buildPythonApplication (finalAttrs: {
  pname = "gpt-cli";
  version = "0.4.3";

  src = fetchFromGitHub {
    owner = "kharvd";
    repo = "gpt-cli";
    tag = "v${finalAttrs.version}";
    hash = "sha256-BNSMxf3rhKieXYnFqVdpiHmNCDjotJUflwa6mAgsVCc=";
  };

  nativeCheckInputs =
    with python3Packages;
    [
      pytestCheckHook
    ]
    ++ [
      versionCheckHook
    ];

  build-system = with python3Packages; [
    pip
    setuptools
  ];

  dependencies = with python3Packages; [
    anthropic
    attrs
    black
    cohere
    google-genai
    google-generativeai
    openai
    prompt-toolkit
    pydantic
    pytest
    pyyaml
    rich
    typing-extensions
  ];

  pyproject = true;
  pythonRelaxDeps = true;
  versionCheckProgram = "${placeholder "out"}/bin/gpt";

  meta = {
    description = "Command-line interface for ChatGPT, Claude and Bard";
    homepage = "https://github.com/kharvd/gpt-cli";
    changelog = "https://github.com/kharvd/gpt-cli/releases/tag/${finalAttrs.src.tag}";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ _404wolf ];
    mainProgram = "gpt";
  };
})
