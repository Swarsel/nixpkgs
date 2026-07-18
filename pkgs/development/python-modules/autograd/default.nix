{
  lib,
  fetchFromGitHub,
  buildPythonPackage,
  # build-system
  hatchling,
  # dependencies
  numpy,
  # tests
  pytest-cov-stub,
  pytest-xdist,
  pytestCheckHook,
}:

buildPythonPackage rec {
  pname = "autograd";
  version = "1.9.0";

  src = fetchFromGitHub {
    owner = "HIPS";
    repo = "autograd";
    tag = "v${version}";
    hash = "sha256-R9l+k4qkxlBW4z4ly0H5wfg4mX7kZv41hZlykMKKui0=";
  };

  postPatch = ''
    # don't require pytest-cov
    sed -i "/required_plugins/d" pyproject.toml
  '';

  nativeCheckInputs = [
    pytest-cov-stub
    pytest-xdist
    pytestCheckHook
  ];

  build-system = [ hatchling ];
  dependencies = [ numpy ];
  pyproject = true;
  pythonImportsCheck = [ "autograd" ];

  meta = {
    description = "Compute derivatives of NumPy code efficiently";
    homepage = "https://github.com/HIPS/autograd";
    changelog = "https://github.com/HIPS/autograd/releases/tag/v${version}";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ jluttine ];
  };
}
