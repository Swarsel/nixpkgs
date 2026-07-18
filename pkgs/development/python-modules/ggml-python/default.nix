{
  lib,
  fetchFromGitHub,
  # optional-dependencies
  accelerate,
  buildPythonPackage,
  cairosvg,
  # build-system
  cmake,
  # buildInputs
  ggml,
  mkdocs,
  mkdocs-material,
  mkdocstrings,
  ninja,
  nix-update-script,
  # dependencies
  numpy,
  pillow,
  # tests
  pytestCheckHook,
  scikit-build-core,
  sentencepiece,
  torch,
  torchaudio,
  torchvision,
  transformers,
  typing-extensions,
}:

buildPythonPackage (finalAttrs: {
  pname = "ggml-python";
  version = "0.0.45";

  src = fetchFromGitHub {
    owner = "abetlen";
    repo = "ggml-python";
    tag = "v${finalAttrs.version}";
    hash = "sha256-rPbYp6if9bCiQGfM7ZC84hkJKadE2mwC9N3elgVfQBc=";
    # ggml-python expects an older version of ggml than pkgs.ggml's
    fetchSubmodules = true;
  };

  buildInputs = [
    ggml
  ];

  nativeCheckInputs = [
    pytestCheckHook
  ];

  preCheck = ''
    rm -rf ggml
  '';

  __structuredAttrs = true;

  build-system = [
    cmake
    ninja
    scikit-build-core
  ];

  dependencies = [
    numpy
    typing-extensions
  ];

  dontUseCmakeConfigure = true;

  optional-dependencies = {
    convert = [
      accelerate
      numpy
      sentencepiece
      torch
      torchaudio
      torchvision
      transformers
    ];

    docs = [
      cairosvg
      mkdocs
      mkdocs-material
      mkdocstrings
      pillow
    ];
  };

  pyproject = true;
  pythonImportsCheck = [ "ggml" ];

  passthru.updateScript = nix-update-script {
    extraArgs = [
      "--version-regex"
      "^v([0-9.]+)$"
    ];
  };

  meta = {
    description = "Python bindings for ggml";
    homepage = "https://github.com/abetlen/ggml-python";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ GaetanLepage ];
  };
})
