{
  lib,
  stdenv,
  appnope,
  buildPythonPackage,
  callPackage,
  comm,
  fetchPypi,
  hatchling,
  ipython,
  jupyter-client,
  jupyter-core,
  matplotlib-inline,
  nest-asyncio,
  packaging,
  psutil,
  pyzmq,
  # Reverse dependency
  sage,
  tornado,
  traitlets,
}:

buildPythonPackage rec {
  pname = "ipykernel";
  version = "7.1.0";

  src = fetchPypi {
    inherit pname version;
    hash = "sha256-WKP8iFM9WTDDVG3H6sZsbSiKzeT4AeIAHmXtxdyc8Ns=";
  };

  nativeBuildInputs = [ hatchling ];

  propagatedBuildInputs = [
    comm
    ipython
    jupyter-client
    jupyter-core
    matplotlib-inline
    nest-asyncio
    packaging
    psutil
    pyzmq
    tornado
    traitlets
  ]
  ++ lib.optionals stdenv.hostPlatform.isDarwin [ appnope ];

  # check in passthru.tests.pytest to escape infinite recursion with ipyparallel
  doCheck = false;
  pyproject = true;
  # debugpy is optional, see https://github.com/ipython/ipykernel/pull/767
  pythonRemoveDeps = [ "debugpy" ];

  passthru.tests = {
    inherit sage;
    pytest = callPackage ./tests.nix { };
  };

  meta = {
    description = "IPython Kernel for Jupyter";
    homepage = "https://ipython.org/";
    changelog = "https://github.com/ipython/ipykernel/releases/tag/v${version}";
    license = lib.licenses.bsd3;
    teams = [ lib.teams.jupyter ];
  };
}
