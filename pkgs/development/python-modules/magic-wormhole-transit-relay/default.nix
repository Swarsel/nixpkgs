{
  lib,
  fetchFromGitHub,
  autobahn,
  buildPythonPackage,
  pytestCheckHook,
  python,
  setuptools,
  twisted,
}:

buildPythonPackage (finalAttrs: {
  pname = "magic-wormhole-transit-relay";
  version = "0.5.0";

  src = fetchFromGitHub {
    owner = "magic-wormhole";
    repo = "magic-wormhole-transit-relay";
    tag = finalAttrs.version;
    hash = "sha256-UhV0M8Nl9Y850PQcJoDyIvIPRyBS8gyF2Ub9qF3aq0U=";
  };

  postPatch = ''
    # Passing the environment to twistd is necessary to preserve Python's site path.
    substituteInPlace src/wormhole_transit_relay/test/test_backpressure.py --replace-fail \
      'reactor.spawnProcess(proto, exe, args)' \
      'reactor.spawnProcess(proto, exe, args, None)'
  '';

  nativeCheckInputs = [
    pytestCheckHook
    twisted
  ];

  postCheck = ''
    # Avoid collision with twisted's plugin cache (#164775).
    rm "$out/${python.sitePackages}/twisted/plugins/dropin.cache"
  '';

  __darwinAllowLocalNetworking = true;
  build-system = [ setuptools ];

  dependencies = [
    autobahn
    twisted
  ];

  pyproject = true;
  pythonImportsCheck = [ "wormhole_transit_relay" ];

  meta = {
    description = "Transit Relay server for Magic-Wormhole";
    homepage = "https://github.com/magic-wormhole/magic-wormhole-transit-relay";
    changelog = "https://github.com/magic-wormhole/magic-wormhole-transit-relay/blob/${finalAttrs.src.rev}/NEWS.md";
    license = lib.licenses.mit;
    maintainers = [ lib.maintainers.mjoerg ];
  };
})
