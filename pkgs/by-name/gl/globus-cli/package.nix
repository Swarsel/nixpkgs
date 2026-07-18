{
  lib,
  fetchFromGitHub,
  installShellFiles,
  python3Packages,
  versionCheckHook,
}:

python3Packages.buildPythonApplication rec {
  pname = "globus-cli";
  version = "3.41.0";

  src = fetchFromGitHub {
    owner = "globus";
    repo = "globus-cli";
    tag = version;
    hash = "sha256-bTS4dXQU49asmPmgUnf4VjAWJ34+1YbXmCJ4KOeOoMI=";
  };

  nativeBuildInputs = [ installShellFiles ];

  nativeCheckInputs = with python3Packages; [
    pytest
    pytest-xdist
    pytest-timeout
    responses

    click
    requests
    pyjwt
    cryptography
    packaging
    typing-extensions

    pytestCheckHook
    versionCheckHook
  ];

  postInstall = ''
    mkdir -p completions/{bash,zsh}
    $out/bin/globus --bash-completer > completions/bash/globus
    $out/bin/globus --zsh-completer > completions/zsh/_globus
    installShellCompletion \
      --bash completions/bash/globus \
      --zsh completions/zsh/_globus
  '';

  build-system = with python3Packages; [
    flit-core
    ruamel-yaml
    flit-core
  ];

  dependencies = with python3Packages; [
    globus-sdk
    click
    jmespath
    packaging
    typing-extensions
    requests
  ];

  pyproject = true;

  pythonRelaxDeps = [
    "globus-sdk"
    "jmespath"
  ];

  versionCheckProgramArg = "version";

  meta = {
    description = "Command-line interface to Globus REST APIs, including the Transfer API and the Globus Auth API";
    homepage = "https://github.com/globus/globus-cli";
    changelog = "https://github.com/globus/globus-cli/releases/tag/${src.tag}";
    license = lib.licenses.asl20;
    maintainers = [ lib.maintainers.richardjacton ];
    mainProgram = "globus";
  };
}
