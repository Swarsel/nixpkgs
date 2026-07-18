{
  lib,
  fetchurl,
  fetchFromGitHub,
  buildPythonPackage,
  einops,
  numpy,
  pytestCheckHook,
  rotary-embedding-torch,
  setuptools,
  soundfile,
  soxr,
  torch,
  torchaudio,
  writableTmpDirAsHomeHook,
}:

buildPythonPackage (finalAttrs: {
  pname = "beat-this";
  version = "1.1.0";

  src = fetchFromGitHub {
    owner = "CPJKU";
    repo = "beat_this";
    tag = "v${finalAttrs.version}";
    hash = "sha256-AEcDptPn5FUBb8+FuYSKjd00sFY5z6bS2iEOU64jido=";
  };

  nativeCheckInputs = [
    pytestCheckHook
    soundfile
    writableTmpDirAsHomeHook
  ];

  preCheck = ''
    mkdir -p $HOME/.cache/torch/hub/checkpoints/
    cp ${finalAttrs.passthru.final0Ckpt} $HOME/.cache/torch/hub/checkpoints/beat_this-final0.ckpt
  '';

  build-system = [ setuptools ];

  dependencies = [
    einops
    numpy
    rotary-embedding-torch
    soxr
    torch
    torchaudio
  ];

  pyproject = true;
  pythonImportsCheck = [ "beat_this" ];

  passthru = {
    # The program prints the download URLs in the error message when it cannot download things in the nix sandbox
    final0Ckpt = fetchurl {
      hash = "sha256-jDKLRfWdjdPf8hklP/ao1kgr5X0BM6KRQOL+u/jrgzE=";
      url = "https://cloud.cp.jku.at/public.php/dav/files/7ik4RrBKTS273gp/final0.ckpt";
    };

    small0Ckpt = fetchurl {
      hash = "sha256-YHS+LE1JDF9hAfzDdKHscq6TRW4ju2AZeDuEn13H1Hs=";
      url = "https://cloud.cp.jku.at/public.php/dav/files/7ik4RrBKTS273gp/small0.ckpt";
    };
  };

  meta = {
    description = "Accurate and general beat tracker";
    homepage = "https://github.com/CPJKU/beat_this";
    changelog = "https://github.com/CPJKU/beat_this/blob/main/CHANGELOG.md";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ SuperSandro2000 ];
  };
})
