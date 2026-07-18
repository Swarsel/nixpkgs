{
  lib,
  fetchFromGitHub,
  buildPythonPackage,
  fetchpatch,
  pytestCheckHook,
  setuptools,
}:

buildPythonPackage rec {
  pname = "propka";
  version = "3.5.1";

  src = fetchFromGitHub {
    owner = "jensengroup";
    repo = "propka";
    tag = "v${version}";
    hash = "sha256-EJQqCe4WPOpqsSxxfbTjF0qETpSPYqpixpylweTCjko=";
  };

  patches = [
    # Upstream PR: https://github.com/jensengroup/propka/pull/202
    (fetchpatch {
      hash = "sha256-tuhUfc7SGjdGxAPcsbrwOyqgTesg7k+FruJjY05YOUs=";
      name = "python-3.14.patch";
      url = "https://github.com/jensengroup/propka/commit/5eb80b7836b2e71b37598d2c7fa06ed8141ff6fd.patch";
    })
  ];

  nativeBuildInputs = [ setuptools ];
  nativeCheckInputs = [ pytestCheckHook ];
  pyproject = true;
  pythonImportsCheck = [ "propka" ];

  meta = {
    description = "Predictor of the pKa values of ionizable groups in proteins and protein-ligand complexes based in the 3D structure";
    homepage = "https://github.com/jensengroup/propka";
    changelog = "https://github.com/jensengroup/propka/releases/tag/v${version}";
    license = lib.licenses.lgpl21Only;
    maintainers = with lib.maintainers; [ natsukium ];
    mainProgram = "propka3";
  };
}
