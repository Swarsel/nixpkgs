{
  lib,
  fetchFromGitLab,
  buildPythonPackage,
  graphviz,
  markdown,
  replaceVars,
  setuptools,
}:

buildPythonPackage rec {
  pname = "mkdocs-graphviz";
  version = "1.5";

  src = fetchFromGitLab {
    owner = "rod2ik";
    repo = "mkdocs-graphviz";
    tag = version;
    hash = "sha256-5pc5RpOrDSONZcgIQMNsVxYwFyJ+PMcIt0GXDxCEyOg=";
  };

  patches = [
    # Replace the path to the `graphviz` commands to use the one provided by Nixpkgs.
    (replaceVars ./replace-path-to-dot.patch {
      command = "\"${graphviz}/bin/\" + command";
    })
  ];

  # Tests are not available in the source code.
  doCheck = false;
  build-system = [ setuptools ];

  dependencies = [
    markdown
  ];

  pyproject = true;
  pythonImportsCheck = [ "mkdocs_graphviz" ];

  meta = {
    description = "Configurable Python markdown extension for graphviz and Mkdocs";
    homepage = "https://gitlab.com/rod2ik/mkdocs-graphviz";
    license = lib.licenses.gpl3Only;
    maintainers = [ ];
  };
}
