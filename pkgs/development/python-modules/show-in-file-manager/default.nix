{
  lib,
  stdenv,
  argparse-manpage,
  buildPythonPackage,
  fetchPypi,
  packaging,
  pyxdg,
  setuptools,
}:

buildPythonPackage rec {
  pname = "show-in-file-manager";
  version = "1.1.5";

  src = fetchPypi {
    inherit pname version;
    hash = "sha256-7ROhgKHUj9iP3UxYv7yzhgJoZBo4gFGSyBTUE4cZLYQ=";
  };

  nativeBuildInputs = [
    argparse-manpage
    setuptools
  ];

  propagatedBuildInputs = [ packaging ] ++ lib.optional (stdenv.hostPlatform.isLinux) pyxdg;
  pyproject = true;

  meta = {
    description = "Open the system file manager and select files in it";

    longDescription = ''
      Show in File Manager is a Python package to open the system file
      manager and optionally select files in it. The point is not to
      open the files, but to select them in the file manager, thereby
      highlighting the files and allowing the user to quickly do
      something with them.
    '';

    homepage = "https://github.com/damonlynch/showinfilemanager";
    license = lib.licenses.mit;
    maintainers = [ ];
    mainProgram = "showinfilemanager";
  };
}
