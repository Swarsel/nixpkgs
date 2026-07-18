{
  lib,
  fetchFromGitHub,
  buildPythonPackage,
  fetchpatch,
  # dependencies
  makefun,
  multipledispatch,
  numpy,
  opt-einsum,
  pandas,
  pillow,
  pyro-api,
  # tests
  pyro-ppl,
  pytest-xdist,
  pytestCheckHook,
  requests,
  scipy,
  # build-system
  setuptools,
  torch,
  torchvision,
  typing-extensions,
}:

buildPythonPackage (finalAttrs: {
  pname = "funsor";
  version = "0.4.7";

  src = fetchFromGitHub {
    owner = "pyro-ppl";
    repo = "funsor";
    tag = finalAttrs.version;
    hash = "sha256-0STJv1OOliJaHdmYUXdnOnocH3hVXceH/Uw5nILvT+U=";
  };

  patches = [
    # Compatibility with torch >= 2.5 (arg_constraints is now a property)
    (fetchpatch {
      hash = "sha256-sTR+hbJtS0Th5sIqlvB2bReEC0wnEbnB7gAiZKiqjAQ=";
      url = "https://github.com/pyro-ppl/funsor/commit/c5e2a48d73cad4e98058147af4090171272a44e5.patch";
    })
  ];

  nativeCheckInputs = [
    # Backend
    pyro-ppl
    torch

    pandas
    pillow
    pyro-api
    pytestCheckHook
    pytest-xdist
    requests
    scipy
    torchvision
  ];

  preCheck = ''
    export FUNSOR_BACKEND=torch
  '';

  __structuredAttrs = true;
  build-system = [ setuptools ];

  dependencies = [
    makefun
    multipledispatch
    numpy
    opt-einsum
    typing-extensions
  ];

  pyproject = true;
  pythonImportsCheck = [ "funsor" ];

  meta = {
    description = "Functional tensors for probabilistic programming";
    homepage = "https://funsor.pyro.ai";
    changelog = "https://github.com/pyro-ppl/funsor/releases/tag/${finalAttrs.src.tag}";
    license = lib.licenses.asl20;
    maintainers = with lib.maintainers; [ GaetanLepage ];
  };
})
