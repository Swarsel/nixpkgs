{
  lib,
  fetchFromGitHub,
  aiohttp-retry,
  asyncssh,
  buildPythonPackage,
  dulwich,
  fsspec,
  funcy,
  gitpython,
  pathspec,
  pygit2,
  pygtrie,
  setuptools,
  setuptools-scm,
  tqdm,
}:

buildPythonPackage (finalAttrs: {
  pname = "scmrepo";
  version = "3.6.2";

  src = fetchFromGitHub {
    owner = "iterative";
    repo = "scmrepo";
    tag = finalAttrs.version;
    hash = "sha256-E7BHdLDS57r/UbSA62lfr3z+5sqFTPRzwfFLIITeSs0=";
  };

  # Requires a running Docker instance
  doCheck = false;

  build-system = [
    setuptools
    setuptools-scm
  ];

  dependencies = [
    aiohttp-retry
    asyncssh
    dulwich
    fsspec
    funcy
    gitpython
    pathspec
    pygit2
    pygtrie
    tqdm
  ];

  pyproject = true;
  pythonImportsCheck = [ "scmrepo" ];

  meta = {
    description = "SCM wrapper and fsspec filesystem";
    homepage = "https://github.com/iterative/scmrepo";
    changelog = "https://github.com/iterative/scmrepo/releases/tag/${finalAttrs.src.tag}";
    license = lib.licenses.asl20;
    maintainers = with lib.maintainers; [ fab ];
  };
})
