{
  lib,
  fetchFromGitHub,
  blst,
  buildPythonPackage,
  clang,
  # checkPhase dependencies
  python,
  # dependencies
  pyyaml,
  setuptools,
}:

buildPythonPackage rec {
  pname = "ckzg";
  version = "2.1.8";

  src = fetchFromGitHub {
    owner = "ethereum";
    repo = "c-kzg-4844";
    tag = "v${version}";
    hash = "sha256-i7m1oFQ4WmY+TfETfQuznvQINt6+JfWztoRFnI/pV/s=";
  };

  postPatch =
    # unvendor "blst"
    ''
      substituteInPlace setup.py \
        --replace-fail '"build_ext": CustomBuild,' ""
    '';

  nativeBuildInputs = [ clang ];

  checkPhase = ''
    runHook preCheck

    cd bindings/python
    ${python.interpreter} tests.py

    runHook postCheck
  '';

  build-system = [ setuptools ];

  dependencies = [
    pyyaml
    blst
  ];

  pyproject = true;
  pythonImportsCheck = [ "ckzg" ];

  meta = {
    description = "Minimal implementation of the Polynomial Commitments API for EIP-4844 and EIP-7594";
    homepage = "https://github.com/ethereum/c-kzg-4844";
    changelog = "https://github.com/ethereum/c-kzg-4844/releases/tag/${src.tag}";
    license = lib.licenses.asl20;
    maintainers = with lib.maintainers; [ hellwolf ];
  };
}
