{
  lib,
  fetchFromGitHub,
  python3,
}:

python3.pkgs.buildPythonApplication (finalAttrs: {
  pname = "git-crecord";
  version = "20230226.0";

  src = fetchFromGitHub {
    owner = "andrewshadura";
    repo = "git-crecord";
    tag = finalAttrs.version;
    sha256 = "sha256-zsrMAD9EU+TvkWfWl9x6WbMXuw7YEz50LxQzSFVkKdQ=";
  };

  # has no tests
  doCheck = false;
  build-system = with python3.pkgs; [ setuptools ];
  dependencies = with python3.pkgs; [ docutils ];
  pyproject = true;

  meta = {
    description = "Git subcommand to interactively select changes to commit or stage";
    homepage = "https://github.com/andrewshadura/git-crecord";
    license = lib.licenses.gpl2Plus;
    maintainers = with lib.maintainers; [ onny ];
    mainProgram = "git-crecord";
  };
})
