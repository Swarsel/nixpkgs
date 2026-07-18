{
  lib,
  fetchFromGitHub,
  python3,
}:

python3.pkgs.buildPythonApplication (finalAttrs: {
  pname = "shell-gpt";
  version = "1.5.1";

  src = fetchFromGitHub {
    owner = "TheR1D";
    repo = "shell_gpt";
    tag = finalAttrs.version;
    hash = "sha256-ZfccaWu/MEY+U+Q8W5N/jcpx7Mv9gRytxjX5qGkMWWk=";
  };

  # Tests want to read the OpenAI API key from stdin
  doCheck = false;
  build-system = with python3.pkgs; [ hatchling ];

  dependencies = with python3.pkgs; [
    distro
    litellm
    openai
    prompt-toolkit
    rich
    typer
  ];

  pyproject = true;

  pythonRelaxDeps = [
    "rich"
    "distro"
    "typer"
    "openai"
    "prompt-toolkit"
  ];

  meta = {
    description = "Access ChatGPT from your terminal";
    homepage = "https://github.com/TheR1D/shell_gpt";
    changelog = "https://github.com/TheR1D/shell_gpt/releases/tag/${finalAttrs.version}";
    license = lib.licenses.mit;

    maintainers = with lib.maintainers; [
      SohamG
      mio
    ];

    mainProgram = "sgpt";
  };
})
