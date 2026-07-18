{
  lib,
  fetchFromGitHub,
  buildPythonPackage,
  ddt,
  igraph,
  igraph-c,
  libleidenalg,
  setuptools-scm,
  unittestCheckHook,
}:

buildPythonPackage (finalAttrs: {
  pname = "leidenalg";
  version = "0.12.0";

  src = fetchFromGitHub {
    owner = "vtraag";
    repo = "leidenalg";
    tag = finalAttrs.version;
    hash = "sha256-E8mFzEVzff3BEt5sPDXy8/ofZgVfzgiUyIqT59/Trd0=";
  };

  buildInputs = [
    igraph-c
    libleidenalg
  ];

  nativeCheckInputs = [
    ddt
    unittestCheckHook
  ];

  build-system = [ setuptools-scm ];
  dependencies = [ igraph ];
  pyproject = true;
  pythonImportsCheck = [ "leidenalg" ];

  meta = {
    description = "Implementation of the Leiden algorithm for various quality functions to be used with igraph in Python";
    homepage = "https://github.com/vtraag/leidenalg";
    changelog = "https://github.com/vtraag/leidenalg/blob/${finalAttrs.src.tag}/CHANGELOG";
    license = lib.licenses.gpl3Plus;
    maintainers = with lib.maintainers; [ jboy ];
  };
})
