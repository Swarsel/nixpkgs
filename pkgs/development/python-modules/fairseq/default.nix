{
  lib,
  fetchFromGitHub,
  bitarray,
  buildPythonPackage,
  # Propagated build inputs
  cffi,
  # Native build inputs
  cython,
  # Check inputs
  expecttest,
  fetchpatch,
  hydra-core,
  hypothesis,
  numpy,
  omegaconf,
  packaging,
  pytestCheckHook,
  regex,
  sacrebleu,
  scikit-learn,
  torch,
  torchaudio,
  tqdm,
  which,
}:

buildPythonPackage rec {
  pname = "fairseq";
  version = "0.12.3";

  src = fetchFromGitHub {
    owner = "pytorch";
    repo = "fairseq";
    rev = "v${version}";
    hash = "sha256-XX/grU5ljQCwx33miGoFc/7Uj9fZDtmhm4Fz7L4U+Bc=";
  };

  patches = [
    # https://github.com/facebookresearch/fairseq/pull/5359
    (fetchpatch {
      hash = "sha256-aYYP/knQX6q6vhyA6q9uOOYfRhDAuJCo9QJWfFEDuuA=";
      url = "https://github.com/facebookresearch/fairseq/commit/2fa0768c2115b0a4c207cfa3e1b3e4ff3ad9a00c.patch";
    })
  ];

  nativeBuildInputs = [
    cython
    which
  ];

  propagatedBuildInputs = [
    cffi
    hydra-core
    omegaconf
    sacrebleu
    numpy
    regex
    torch
    tqdm
    bitarray
    torchaudio
    scikit-learn
    packaging
  ];

  nativeCheckInputs = [
    expecttest
    hypothesis
    pytestCheckHook
  ];

  preCheck = ''
    export HOME=$TMPDIR
    cd tests
  '';

  disabledTestPaths = [
    # ValueError: mutable default ... for field bar is not allowed: use default_factory
    "test_dataclass_utils.py"
  ];

  disabledTests = [
    # this test requires xformers
    "test_xformers_single_forward_parity"
    "test_mask_for_xformers"
    # this test requires iopath
    "test_file_io_async"
    # these tests require network access
    "test_s2s_transformer_checkpoint"
    "test_librispeech_s2t_transformer_s_checkpoint"
    "test_s2s_transformer_checkpoint"
    "test_waitk_checkpoint"
    "test_sotasty_es_en_600m_checkpoint"
    "test_librispeech_s2t_conformer_s_checkpoint"
    # TODO research failure
    "test_multilingual_translation_latent_depth"
  ];

  pyproject = true;
  pytestFlags = [ "--import-mode=append" ];
  pythonImportsCheck = [ "fairseq" ];

  pythonRelaxDeps = [
    "hydra-core"
    "omegaconf"
    "torchaudio"
  ];

  meta = {
    description = "Facebook AI Research Sequence-to-Sequence Toolkit";
    homepage = "https://github.com/pytorch/fairseq";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ happysalada ];
    platforms = lib.platforms.linux;
    broken = true; # requires numpy1 which is incompatible with sacrebleu depending on numpy2
    hydraPlatforms = [ ];
  };
}
