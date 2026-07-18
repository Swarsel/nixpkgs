{
  lib,
  fetchFromGitHub,
  buildPythonPackage,
  flax,
  jax,
  jaxlib,
  setuptools,
  transformers,
}:

buildPythonPackage {
  pname = "vqgan-jax";
  version = "unstable-2022-04-20";

  src = fetchFromGitHub {
    owner = "patil-suraj";
    repo = "vqgan-jax";
    rev = "1be20eee476e5d35c30e4ec3ed12222018af8ce4";
    hash = "sha256-OZihAXpE0UsgauQ38XDmAF+lrIgz05uK0ro8SCdVsPc=";
  };

  buildInputs = [ jaxlib ];
  doCheck = false;
  __structuredAttrs = true;
  build-system = [ setuptools ];

  dependencies = [
    flax
    jax
    transformers
  ];

  pyproject = true;
  pythonImportsCheck = [ "vqgan_jax" ];

  meta = {
    description = "JAX implementation of VQGAN";
    homepage = "https://github.com/patil-suraj/vqgan-jax";
    # license unknown: https://github.com/patil-suraj/vqgan-jax/issues/9
    license = lib.licenses.unfree;
    maintainers = with lib.maintainers; [ r-burns ];
  };
}
