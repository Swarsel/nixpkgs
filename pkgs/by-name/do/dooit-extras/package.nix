{
  lib,
  fetchFromGitHub,
  dooit,
  nix-update-script,
  python3,
}:
python3.pkgs.buildPythonPackage rec {
  pname = "dooit-extras";
  version = "0.2.1";

  src = fetchFromGitHub {
    owner = "dooit-org";
    repo = "dooit-extras";
    tag = "v${version}";
    hash = "sha256-h29lN32Qca8edF1aLhLxnV97MMEapX3Docc+CIEF6I4=";
  };

  buildInputs = [ dooit ];
  # No tests available
  doCheck = false;
  build-system = with python3.pkgs; [ poetry-core ];
  pyproject = true;

  passthru.updateScript = nix-update-script {
  };

  meta = {
    description = "Extra Utilities for Dooit";
    homepage = "https://github.com/dooit-org/dooit-extras";
    changelog = "https://github.com/dooit-org/dooit-extras/blob/${src.tag}/CHANGELOG.md";
    license = lib.licenses.mit;

    maintainers = with lib.maintainers; [
      kraanzu
    ];
  };
}
