{
  lib,
  fetchFromGitHub,
  buildPythonPackage,
  # build-system
  setuptools,
  # dependencies
  typing-extensions,
}:
let
  pname = "torcheval";
  version = "0.0.7";
in

# nixpkgs-update: no auto update
# upstream is missing the tag, so r-ryantm is attempting downgrades, e.g. #460611
buildPythonPackage {
  inherit pname version;

  src = fetchFromGitHub {
    owner = "meta-pytorch";
    repo = "torcheval";
    # Upstream has not created a tag for this version
    # https://github.com/pytorch/torcheval/issues/215
    rev = "f1bc22fc67ec2c77ee519aa4af8079f4fdaa41bb";
    hash = "sha256-aVr4qKKE+dpBcJEi1qZJBljFLUl8d7D306Dy8uOojJE=";
  };

  # Tests are very flaky and computationally intensive
  doCheck = false;
  build-system = [ setuptools ];
  dependencies = [ typing-extensions ];
  pyproject = true;
  pythonImportsCheck = [ "torcheval" ];

  meta = {
    description = "Rich collection of performant PyTorch model metrics and tools for PyTorch model evaluations";
    homepage = "https://pytorch.org/torcheval";
    changelog = "https://github.com/meta-pytorch/torcheval/releases/tag/${version}";
    license = [ lib.licenses.bsd3 ];
    maintainers = [ lib.maintainers.bengsparks ];
    platforms = lib.platforms.unix;
  };
}
