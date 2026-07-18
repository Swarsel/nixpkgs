{
  lib,
  buildPythonPackage,
  dulwich,
  fetchPypi,
  mercurial,
  setuptools,
  setuptools-scm,
}:

buildPythonPackage rec {
  pname = "hg-git";
  version = "1.2.0";

  src = fetchPypi {
    inherit version;
    hash = "sha256-Pr+rNkqBubVlsQCyqd5mdr8D357FzSd3Kuz5EWeez8M=";
    pname = "hg_git";
  };

  # the dulwich version we are using is ahead of the one used upstream by hg-git.
  # the build was failing because it could not import 'ANNOTATED_TAG_SUFFIX' from
  # 'dulwich.refs'.
  patches = [ ./dulwich_ANNOTATED_TAG_SUFFIX_renamed.patch ];

  build-system = [
    setuptools
    setuptools-scm
  ];

  dependencies = [
    dulwich
    mercurial
  ];

  pyproject = true;
  pythonImportsCheck = [ "hggit" ];
  pythonRelaxDeps = [ "dulwich" ];

  meta = {
    description = "Push and pull from a Git server using Mercurial";
    homepage = "https://hg-git.github.io/";
    license = lib.licenses.gpl2Only;
    maintainers = with lib.maintainers; [ koral ];
  };
}
