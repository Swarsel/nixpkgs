{
  lib,
  buildPythonPackage,
  fetchPypi,
  gql,
  nix-update-script,
  uv-build,
}:

buildPythonPackage (finalAttrs: {
  pname = "caido-server-auth";
  version = "0.1.2";

  src = fetchPypi {
    inherit (finalAttrs) version;
    hash = "sha256-6ywl6d4VBidgtoES9djprWPusTIlGLkMGgEZppp1JKQ=";
    pname = "caido_server_auth";
  };

  postPatch = ''
    substituteInPlace pyproject.toml \
      --replace-fail "uv_build>=0.9.8,<0.10.0" "uv_build"
  '';

  # Module has no tests
  doCheck = false;
  __structuredAttrs = true;
  build-system = [ uv-build ];

  dependencies = [
    gql
  ]
  ++ gql.optional-dependencies.aiohttp
  ++ gql.optional-dependencies.websockets;

  pyproject = true;
  pythonImportsCheck = [ "caido_server_auth" ];
  passthru.updateScript = nix-update-script { };

  meta = {
    description = "Authenticate with a Caido instance";
    homepage = "https://github.com/caido-community/sdk-py/tree/main/packages/caido-server-auth";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ fab ];
  };
})
