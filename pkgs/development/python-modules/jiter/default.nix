{
  lib,
  fetchFromGitHub,
  buildPythonPackage,
  dirty-equals,
  libiconv,
  nix-update-script,
  pytestCheckHook,
  rustPlatform,
}:

buildPythonPackage rec {
  pname = "jiter";
  version = "0.12.0";

  src = fetchFromGitHub {
    owner = "pydantic";
    repo = "jiter";
    tag = "v${version}";
    hash = "sha256-d87RUXKEmZXxVQZnAvjwRKSP6F3Z+kXxg/LdY2l9B+k=";
  };

  postPatch = ''
    cp ${./Cargo.lock} Cargo.lock
  '';

  nativeBuildInputs = [ rustPlatform.cargoSetupHook ];
  buildInputs = [ libiconv ];

  nativeCheckInputs = [
    dirty-equals
    pytestCheckHook
  ];

  build-system = [ rustPlatform.maturinBuildHook ];
  buildAndTestSubdir = "crates/jiter-python";
  cargoDeps = rustPlatform.importCargoLock { lockFile = ./Cargo.lock; };
  pyproject = true;
  pythonImportsCheck = [ "jiter" ];
  passthru.updateScript = nix-update-script { extraArgs = [ "--generate-lockfile" ]; };

  meta = {
    description = "Fast iterable JSON parser";
    homepage = "https://github.com/pydantic/jiter/";
    changelog = "https://github.com/pydantic/jiter/releases/tag/v${version}";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ natsukium ];
  };
}
