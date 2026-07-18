{
  lib,
  fetchFromGitHub,
  anthropic,
  astor,
  buildPythonPackage,
  fastapi,
  google-generativeai,
  html2image,
  html2text,
  inquirer,
  ipykernel,
  jupyter-client,
  litellm,
  matplotlib,
  nltk,
  platformdirs,
  poetry-core,
  psutil,
  pyautogui,
  pydantic,
  pyperclip,
  pyyaml,
  rich,
  selenium,
  send2trash,
  setuptools,
  shortuuid,
  six,
  starlette,
  tiktoken,
  tokentrim,
  toml,
  typer,
  uvicorn,
  webdriver-manager,
  wget,
  yaspin,
}:

buildPythonPackage rec {
  pname = "open-interpreter";
  version = "0.4.2";

  src = fetchFromGitHub {
    owner = "KillianLucas";
    repo = "open-interpreter";
    tag = "v${version}";
    hash = "sha256-fogCcWAhcrCrrcV0q4oKttkf/GeJaJSZnbgiFxvySs8=";
  };

  # Most tests required network access
  doCheck = false;
  build-system = [ poetry-core ];

  dependencies = [
    anthropic
    astor
    fastapi
    google-generativeai
    html2image
    html2text
    inquirer
    ipykernel
    jupyter-client
    litellm
    matplotlib
    platformdirs
    psutil
    pyautogui
    pydantic
    pyperclip
    pyyaml
    rich
    selenium
    send2trash
    setuptools
    shortuuid
    six
    starlette
    tiktoken
    tokentrim
    toml
    typer
    uvicorn
    webdriver-manager
    wget
    yaspin

    # marked optional in pyproject.toml but still required?
    nltk
  ];

  pyproject = true;
  pythonImportsCheck = [ "interpreter" ];

  pythonRelaxDeps = [
    "anthropic"
    "google-generativeai"
    "html2text"
    "psutil"
    "rich"
    "starlette"
    "tiktoken"
    "typer"
    "yaspin"
  ];

  pythonRemoveDeps = [ "git-python" ];

  meta = {
    description = "OpenAI's Code Interpreter in your terminal, running locally";
    homepage = "https://github.com/KillianLucas/open-interpreter";
    changelog = "https://github.com/KillianLucas/open-interpreter/releases/tag/v${version}";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ happysalada ];
    mainProgram = "interpreter";
    broken = true;
  };
}
