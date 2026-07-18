{
  lib,
  fetchFromGitHub,
  fetchpatch,
  installShellFiles,
  python3,
}:

python3.pkgs.buildPythonApplication (finalAttrs: {
  pname = "watson";
  version = "2.1.0";

  src = fetchFromGitHub {
    owner = "jazzband";
    repo = "Watson";
    rev = finalAttrs.version;
    sha256 = "sha256-/AASYeMkt18KPJljAjNPRYOpg/T5xuM10LJq4LrFD0g=";
  };

  patches = [
    # https://github.com/jazzband/Watson/pull/473
    (fetchpatch {
      name = "fix-completion.patch";
      sha256 = "sha256-v8/asP1wooHKjyy9XXB4Rtf6x+qmGDHpRoHEne/ZCxc=";
      url = "https://github.com/jazzband/Watson/commit/43ad061a981eb401c161266f497e34df891a5038.patch";
    })
  ];

  nativeBuildInputs = [ installShellFiles ];

  nativeCheckInputs = with python3.pkgs; [
    pytestCheckHook
    pytest-mock
    mock
    pytest-datafiles
  ];

  postInstall = ''
    installShellCompletion --bash --name watson watson.completion
    installShellCompletion --zsh --name _watson watson.zsh-completion
    installShellCompletion --fish watson.fish
  '';

  build-system = with python3.pkgs; [ setuptools ];

  dependencies = with python3.pkgs; [
    arrow
    click
    click-didyoumean
    requests
  ];

  pyproject = true;
  pythonImportsCheck = [ "watson" ];

  meta = {
    description = "Wonderful CLI to track your time";
    homepage = "https://github.com/jazzband/Watson";
    license = lib.licenses.mit;

    maintainers = with lib.maintainers; [
      mguentner
      nathyong
    ];

    mainProgram = "watson";
  };
})
