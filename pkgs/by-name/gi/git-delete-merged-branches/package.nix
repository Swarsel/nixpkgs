{
  lib,
  fetchFromGitHub,
  git,
  python3Packages,
}:

python3Packages.buildPythonApplication (finalAttrs: {
  pname = "git-delete-merged-branches";
  version = "7.5.1";

  src = fetchFromGitHub {
    owner = "hartwork";
    repo = "git-delete-merged-branches";
    tag = finalAttrs.version;
    sha256 = "sha256-wy5SLaw6QBvbmcFFgtIQ9MhGliW2/ZmCozEa2ZF0Lnc=";
  };

  nativeCheckInputs = [ git ] ++ (with python3Packages; [ parameterized ]);
  build-system = with python3Packages; [ setuptools ];

  dependencies = with python3Packages; [
    colorama
    prompt-toolkit
  ];

  pyproject = true;

  meta = {
    description = "Command-line tool to delete merged Git branches";
    homepage = "https://github.com/hartwork/git-delete-merged-branches/";
    license = lib.licenses.gpl3Plus;
    maintainers = with lib.maintainers; [ SuperSandro2000 ];
  };
})
