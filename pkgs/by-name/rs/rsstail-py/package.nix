{
  lib,
  fetchPypi,
  python3,
}:
python3.pkgs.buildPythonApplication (finalAttrs: {
  pname = "rsstail-py";
  version = "0.6.0";

  src = fetchPypi {
    inherit (finalAttrs) version;
    hash = "sha256-nAqk8qomG02SVq2cbQAO0MidGbxCHCk2kPNB+7YgGOQ=";
    pname = "rsstail";
  };

  build-system = with python3.pkgs; [ setuptools ];
  dependencies = with python3.pkgs; [ feedparser ];
  pyproject = true;

  meta = {
    description = "Command-line syndication feed monitor";
    homepage = "https://github.com/gvalkov/rsstail.py";
    changelog = "https://github.com/gvalkov/rsstail.py/releases/tag/v${finalAttrs.version}";
    license = lib.licenses.bsd3;
    maintainers = with lib.maintainers; [ zoriya ];
    mainProgram = "rsstail";
  };
})
