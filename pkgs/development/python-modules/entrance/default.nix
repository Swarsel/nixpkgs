{
  lib,
  buildPythonPackage,
  fetchPypi,
  janus,
  ncclient,
  paramiko,
  pyyaml,
  routerFeatures,
  sanic,
  setuptools,
}:

let
  # The `routerFeatures` flag optionally brings in some somewhat heavy
  # dependencies, in order to enable interacting with routers
  opts =
    if routerFeatures then
      {
        extraBuildInputs = [
          janus
          ncclient
          paramiko
        ];

        prePatch = ''
          substituteInPlace ./setup.py --replace-fail "extra_deps = []" "extra_deps = router_feature_deps"
        '';
      }
    else
      {
        extraBuildInputs = [ ];
        prePatch = "";
      };
in

buildPythonPackage rec {
  pname = "entrance";
  version = "1.1.21";

  src = fetchPypi {
    inherit pname version;
    hash = "sha256-1rKQPIhnVVtM93K3Ppg+m4/L4k0YD+mcE9bZhDmfmbo=";
  };

  # The versions of `sanic` and `websockets` in nixpkgs only support 3.6 or later
  # No useful tests
  doCheck = false;
  build-system = [ setuptools ];

  dependencies = [
    pyyaml
    sanic
  ]
  ++ opts.extraBuildInputs;

  prePatch = opts.prePatch;
  pyproject = true;

  meta = {
    description = "Server framework for web apps with an Elm frontend";
    homepage = "https://github.com/ensoft/entrance";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ simonchatts ];
  };
}
