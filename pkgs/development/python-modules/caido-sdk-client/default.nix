{
  lib,
  buildPythonPackage,
  caido-server-auth,
  fetchPypi,
  gql,
  nix-update-script,
  pydantic,
  uv-build,
}:

buildPythonPackage (finalAttrs: {
  pname = "caido-sdk-client";
  version = "0.2.0";

  src = fetchPypi {
    inherit (finalAttrs) version;
    hash = "sha256-OZiP4Hs/qcaa29SWYttmDXcH1g2SRRCbFiPe+Xs5usg=";
    pname = "caido_sdk_client";
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
    caido-server-auth
    gql
    pydantic
  ]
  ++ gql.optional-dependencies.aiohttp
  ++ gql.optional-dependencies.websockets;

  pyproject = true;
  pythonImportsCheck = [ "caido_sdk_client" ];
  passthru.updateScript = nix-update-script { };

  meta = {
    description = "Client SDK for interacting with a Caido instance";
    homepage = "https://pypi.org/project/caido-sdk-client";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ fab ];
  };
})
