{
  lib,
  fetchFromGitHub,
  python3,
}:

python3.pkgs.buildPythonPackage rec {
  pname = "md-tangle";
  version = "1.4.4";

  # By some strange reason, fetchPypi fails miserably
  src = fetchFromGitHub {
    owner = "joakimmj";
    repo = "md-tangle";
    tag = "v${version}";
    hash = "sha256-PkOKSsyY8uwS4mhl0lB+KGeUvXfEc7PUDHZapHMYv4c=";
  };

  # Pure Python application, uses only standard modules and comes without
  # testing suite
  doCheck = false;
  build-system = with python3.pkgs; [ setuptools ];
  pyproject = true;
  pythonImportsCheck = [ "md_tangle" ];

  meta = {
    description = "Generates (\"tangles\") source code from Markdown documents";
    homepage = "https://github.com/joakimmj/md-tangle/";
    license = lib.licenses.mit;
    maintainers = [ ];
    mainProgram = "md-tangle";
  };
}
