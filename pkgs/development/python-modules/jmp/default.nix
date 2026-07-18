{
  lib,
  fetchFromGitHub,
  buildPythonPackage,
  jax,
  jaxlib,
  pytestCheckHook,
}:

buildPythonPackage rec {
  pname = "jmp";
  version = "0.0.4";

  src = fetchFromGitHub {
    owner = "deepmind";
    repo = "jmp";
    tag = "v${version}";
    hash = "sha256-+PefZU1209vvf1SfF8DXiTvKYEnZ4y8iiIr8yKikx9Y=";
  };

  # Wheel requires only `numpy`, but the import needs `jax`.
  propagatedBuildInputs = [ jax ];

  nativeCheckInputs = [
    jaxlib
    pytestCheckHook
  ];

  format = "setuptools";
  pythonImportsCheck = [ "jmp" ];

  meta = {
    description = "This library implements support for mixed precision training in JAX";
    homepage = "https://github.com/deepmind/jmp";
    license = lib.licenses.asl20;
    maintainers = with lib.maintainers; [ ndl ];
  };
}
