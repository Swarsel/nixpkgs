{
  lib,
  fetchFromGitHub,
  python3,
}:

python3.pkgs.buildPythonApplication (finalAttrs: {
  pname = "exposor";
  version = "1.0.0";

  src = fetchFromGitHub {
    owner = "abuyv";
    repo = "exposor";
    tag = "v${finalAttrs.version}";
    hash = "sha256-D/AMoLMUUjiKbrDS90GkVLHncMHSmtfjLINf97LEU1w=";
  };

  postPatch = ''
    # File contains unknown property
    rm pyproject.toml
  '';

  # Project has no tests
  doCheck = false;
  build-system = with python3.pkgs; [ setuptools ];

  dependencies = with python3.pkgs; [
    python-dotenv
    pyyaml
    requests
  ];

  pyproject = true;
  pythonImportsCheck = [ "exposor" ];

  meta = {
    description = "Tool using internet search engines to detect exposed technologies with a unified syntax";
    homepage = "https://github.com/abuyv/exposor";
    changelog = "https://github.com/abuyv/exposor/releases/tag/v${finalAttrs.version}";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ fab ];
    mainProgram = "exposor";
  };
})
