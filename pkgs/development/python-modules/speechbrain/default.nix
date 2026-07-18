{
  lib,
  fetchFromGitHub,
  buildPythonPackage,
  # dependencies
  huggingface-hub,
  hyperpyyaml,
  joblib,
  numpy,
  packaging,
  requests,
  scipy,
  sentencepiece,
  # build-system
  setuptools,
  soundfile,
  torch,
  torchaudio,
  tqdm,
}:

buildPythonPackage (finalAttrs: {
  pname = "speechbrain";
  version = "1.1.0";

  src = fetchFromGitHub {
    owner = "speechbrain";
    repo = "speechbrain";
    tag = "v${finalAttrs.version}";
    hash = "sha256-98g9HSCD6ahsmCSKSKIY1okYOuzUqVuJO9N9WUiZMPk=";
  };

  doCheck = false; # requires sox backend
  build-system = [ setuptools ];

  dependencies = [
    huggingface-hub
    hyperpyyaml
    joblib
    numpy
    packaging
    requests
    scipy
    sentencepiece
    soundfile
    torch
    torchaudio
    tqdm
  ];

  pyproject = true;
  pythonImportsCheck = [ "speechbrain" ];

  meta = {
    description = "PyTorch-based Speech Toolkit";
    homepage = "https://speechbrain.github.io";
    changelog = "https://github.com/speechbrain/speechbrain/releases/tag/${finalAttrs.src.tag}";
    license = lib.licenses.asl20;
    maintainers = with lib.maintainers; [ GaetanLepage ];
  };
})
