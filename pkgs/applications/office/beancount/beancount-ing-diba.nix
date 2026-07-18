{
  lib,
  fetchFromGitHub,
  beancount,
  beangulp,
  python3,
}:

python3.pkgs.buildPythonApplication rec {
  pname = "beancount-ing-diba";
  version = "1.1.0";

  src = fetchFromGitHub {
    owner = "siddhantgoel";
    repo = "beancount-ing";
    rev = "v${version}";
    sha256 = "sha256-zjwajl+0ix4wnW0bf4MAuO9Lr9F8sBv87TIL5Ghmlxg=";
  };

  nativeBuildInputs = with python3.pkgs; [
    poetry-core
  ];

  propagatedBuildInputs = [
    beancount
    beangulp
  ];

  pyproject = true;

  meta = {
    description = "Beancount Importers for ING-DiBa (Germany) CSV Exports";
    homepage = "https://github.com/siddhantgoel/beancount-ing";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ matthiasbeyer ];
  };
}
