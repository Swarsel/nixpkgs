{
  lib,
  fetchFromGitHub,
  attrs,
  buildPythonPackage,
  googleapis-common-protos,
  grpcio,
  httpx,
  poetry-core,
  protobuf,
  pygments,
  pyopenssl,
  pytestCheckHook,
  python-dateutil,
  pyyaml,
  semver,
  typing-extensions,
}:

buildPythonPackage rec {
  pname = "dazl";
  version = "8.9.0";

  src = fetchFromGitHub {
    owner = "digital-asset";
    repo = "dazl-client";
    tag = "v${version}";
    hash = "sha256-ZJBaamazyNAYU5xbUvNGLUV5OsyymCdJCoUvoUlIkm4=";
  };

  # daml: command not found
  doCheck = false;

  nativeCheckInputs = [
    pytestCheckHook
    pyyaml
  ];

  build-system = [ poetry-core ];

  dependencies = [
    attrs
    httpx
    python-dateutil
    googleapis-common-protos
    grpcio
    protobuf
    semver
    typing-extensions
  ];

  optional-dependencies = {
    pygments = [ pygments ];
    tls-testing = [ pyopenssl ];
  };

  pyproject = true;
  pythonImportsCheck = [ "dazl" ];

  pythonRelaxDeps = [
    "grpcio"
    "httpx"
  ];

  meta = {
    description = "High-level Ledger API client for Daml ledgers";
    homepage = "https://github.com/digital-asset/dazl-client";
    changelog = "https://github.com/digital-asset/dazl-client/releases/tag/${src.tag}";
    license = lib.licenses.asl20;
  };
}
