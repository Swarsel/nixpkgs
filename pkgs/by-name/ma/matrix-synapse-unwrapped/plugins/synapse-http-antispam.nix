{
  lib,
  fetchFromGitHub,
  buildPythonPackage,
  hatchling,
  matrix-synapse-unwrapped,
  nix-update-script,
  twisted,
}:

buildPythonPackage rec {
  pname = "synapse-http-antispam";
  version = "0.5.0";

  src = fetchFromGitHub {
    owner = "maunium";
    repo = "synapse-http-antispam";
    tag = "v${version}";
    hash = "sha256-hACoTd3qhmw4jfCphCYKm0lJzda4HVlRjyKjql6fte8=";
  };

  buildInputs = [ matrix-synapse-unwrapped ];
  build-system = [ hatchling ];
  dependencies = [ twisted ];
  pyproject = true;
  pythonImportsCheck = [ "synapse_http_antispam" ];
  passthru.updateScript = nix-update-script { };

  meta = {
    description = "Synapse module that forwards spam checking to an HTTP server";
    homepage = "https://github.com/maunium/synapse-http-antispam";
    changelog = "https://github.com/maunium/synapse-http-antispam/releases/tag/v${version}";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ sumnerevans ];
  };
}
