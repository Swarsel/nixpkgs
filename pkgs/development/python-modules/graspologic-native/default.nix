{
  lib,
  fetchFromGitHub,
  buildPythonPackage,
  libiconv,
  pytestCheckHook,
  rustPlatform,
}:

buildPythonPackage rec {
  pname = "graspologic-native";
  version = "1.2.5";

  src = fetchFromGitHub {
    owner = "graspologic-org";
    repo = "graspologic-native";
    tag = version;
    hash = "sha256-JIFg+JIxRKXgWLAGgOyKZTe2gXa8wZW5pEubTBLqwmQ=";
  };

  postPatch = ''
    ln -s ${./Cargo.lock} Cargo.lock
  '';

  nativeBuildInputs = [ rustPlatform.cargoSetupHook ];
  buildInputs = [ libiconv ];
  nativeCheckInputs = [ pytestCheckHook ];

  preCheck = ''
    cd packages/pyo3
  '';

  build-system = [ rustPlatform.maturinBuildHook ];
  buildAndTestSubdir = "packages/pyo3";
  cargoDeps = rustPlatform.importCargoLock { lockFile = ./Cargo.lock; };
  pyproject = true;
  pythonImportsCheck = [ "graspologic_native" ];

  meta = {
    description = "Library of rust components to add additional capability to graspologic a python library for intelligently building networks and network embeddings, and for analyzing connected data";
    homepage = "https://github.com/graspologic-org/graspologic-native";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ natsukium ];
  };
}
