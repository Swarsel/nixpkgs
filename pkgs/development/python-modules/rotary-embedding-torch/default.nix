{
  lib,
  fetchFromGitHub,
  # dependencies
  beartype,
  buildPythonPackage,
  einops,
  # build-system
  setuptools,
  torch,
  wheel,
}:

buildPythonPackage rec {
  pname = "rotary-embedding-torch";
  version = "0.8.9";

  src = fetchFromGitHub {
    owner = "lucidrains";
    repo = "rotary-embedding-torch";
    tag = version;
    hash = "sha256-mPiOtEmRtn73KGoYMum80q0iETJa9zZW9KIWL8O0dnM=";
  };

  nativeBuildInputs = [
    setuptools
    wheel
  ];

  propagatedBuildInputs = [
    beartype
    einops
    torch
  ];

  doCheck = false; # no tests
  pyproject = true;
  pythonImportsCheck = [ "rotary_embedding_torch" ];

  meta = {
    description = "Implementation of Rotary Embeddings, from the Roformer paper, in Pytorch";
    homepage = "https://github.com/lucidrains/rotary-embedding-torch";
    changelog = "https://github.com/lucidrains/rotary-embedding-torch/releases/tag/${src.tag}";
    license = lib.licenses.mit;
    teams = [ lib.teams.tts ];
  };
}
