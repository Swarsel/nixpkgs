{
  lib,
  buildPythonPackage,
  fetchPypi,
  setuptools,
}:

buildPythonPackage rec {
  pname = "mac-alias";
  version = "2.2.3";

  src = fetchPypi {
    inherit version;
    hash = "sha256-HH+jZ2h9ZpefLOTRqLJxbPHJ+4EXQcqzzzyjVlVcK+s=";
    pname = "mac_alias";
  };

  postPatch = ''
    substituteInPlace pyproject.toml --replace-fail "setuptools==80.9.0" "setuptools"
  '';

  nativeBuildInputs = [ setuptools ];
  # pypi package does not include tests;
  # tests anyway require admin privileges to succeed
  doCheck = false;
  pyproject = true;
  pythonImportsCheck = [ "mac_alias" ];

  meta = {
    description = "Generate or read binary Alias and Bookmark records from Python code";

    longDescription = ''
      mac_alias lets you generate or read binary Alias and Bookmark records from Python code.

      While it is written in pure Python, some OS X specific code is required
      to generate a proper Alias or Bookmark record for a given file,
      so this module currently is not portable to other platforms.
    '';

    homepage = "https://github.com/al45tair/mac_alias";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ siriobalmelli ];
    mainProgram = "mac_alias";
  };
}
