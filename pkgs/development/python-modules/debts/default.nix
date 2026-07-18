{
  lib,
  fetchFromGitLab,
  buildPythonPackage,
  jinja2,
  pytest,
  python,
}:

buildPythonPackage rec {
  pname = "debts";
  version = "0.5";

  # pypi does not ship tests
  src = fetchFromGitLab {
    owner = "almet";
    repo = "debts";
    rev = "d887bd8b340172d1c9bbcca6426529b8d1c2a241"; # no tags
    sha256 = "1d66nka81mv9c07mki78lp5hdajqv4cq6aq2k7bh3mhkc5hwnwlg";
    domain = "framagit.org";
  };

  propagatedBuildInputs = [ jinja2 ];
  nativeCheckInputs = [ pytest ];

  # for some reason tests only work if the module is properly installed
  checkPhase = ''
    rm -r debts
    export PYTHONPATH=$out/${python.sitePackages}:$PYTHONPATH
    py.test tests
  '';

  format = "setuptools";

  meta = {
    inherit (src.meta) homepage;
    description = "Simple library and cli-tool to help you solve some debts settlement scenarios";
    license = lib.licenses.beerware;
    maintainers = [ lib.maintainers.symphorien ];
    mainProgram = "debts";
  };
}
