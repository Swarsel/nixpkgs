{
  lib,
  fetchFromGitHub,
  # dependencies
  arviz,
  buildPythonPackage,
  cachetools,
  cloudpickle,
  numpy,
  pandas,
  pytensor,
  rich,
  scipy,
  # build-system
  setuptools,
  threadpoolctl,
  typing-extensions,
  versioneer,
}:

buildPythonPackage (finalAttrs: {
  pname = "pymc";
  version = "6.1.0";

  src = fetchFromGitHub {
    owner = "pymc-devs";
    repo = "pymc";
    tag = "v${finalAttrs.version}";
    hash = "sha256-veJ42myRo23JXh33qC1OXxiGVI0VAARuYKVs7ObFr+Q=";
  };

  # The test suite is computationally intensive and test failures are not
  # indicative for package usability hence tests are disabled by default.
  doCheck = false;
  __structuredAttrs = true;

  build-system = [
    setuptools
    versioneer
  ];

  dependencies = [
    arviz
    cachetools
    cloudpickle
    numpy
    pandas
    pytensor
    rich
    scipy
    threadpoolctl
    typing-extensions
  ];

  pyproject = true;
  pythonImportsCheck = [ "pymc" ];

  meta = {
    description = "Bayesian estimation, particularly using Markov chain Monte Carlo (MCMC)";
    homepage = "https://github.com/pymc-devs/pymc";
    changelog = "https://github.com/pymc-devs/pymc/releases/tag/${finalAttrs.src.tag}";
    license = lib.licenses.asl20;

    maintainers = with lib.maintainers; [
      nidabdella
    ];
  };
})
