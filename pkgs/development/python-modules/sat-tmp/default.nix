{
  lib,
  buildPythonPackage,
  fetchhg,
  setuptools,
  wokkel,
}:

buildPythonPackage rec {
  pname = "sat-tmp";
  version = "0.8.0";

  src = fetchhg {
    url = "https://repos.goffi.org/sat_tmp";
    rev = "v${version}";
    hash = "sha256-CEy0/eaPK0nHzsiJq3m7edNyxzAhfwBaNhFhLS0azOw=";
  };

  # no pytest tests exist
  doCheck = false;
  build-system = [ setuptools ];
  dependencies = [ wokkel ];
  pyproject = true;

  # Taken from import_test.py
  pythonImportsCheck = [
    "sat_tmp.wokkel.pubsub"
    "sat_tmp.wokkel.rsm"
    "sat_tmp.wokkel.mam"
  ];

  # Default-added updateScript doesn't handle Mercurial sources
  passthru.updateScript = null;

  meta = {
    description = "Libervia temporary third party patches";

    longDescription = ''
      This module is used by Libervia project (formerly “Salut à Toi”) project to patch third party modules
      when the patches are not yet available upstream. Patches are removed from this module once merged upstream.
    '';

    homepage = "https://libervia.org";
    license = lib.licenses.agpl3Plus;
    maintainers = [ lib.maintainers.ethancedwards8 ];
    teams = [ lib.teams.ngi ];
  };
}
