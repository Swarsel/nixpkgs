{
  lib,
  fetchFromGitHub,
  buildPythonPackage,
  setuptools-scm,
}:
buildPythonPackage rec {
  pname = "git-find-repos";
  version = "2.1.1";

  src = fetchFromGitHub {
    owner = "acroz";
    repo = "git-find-repos";
    rev = version;
    sha256 = "sha256-+MiCMgIakpJaWWdN2grerlPbPAnfIXuclvRw8XQ1YiI=";
  };

  build-system = [ setuptools-scm ];
  pyproject = true;

  meta = {
    description = "Simple CLI tool for finding git repositories";
    homepage = "https://github.com/acroz/git-find-repos";
    license = lib.licenses.mit;
    maintainers = [ lib.maintainers.yajo ];
    mainProgram = "git-find-repos";
  };
}
