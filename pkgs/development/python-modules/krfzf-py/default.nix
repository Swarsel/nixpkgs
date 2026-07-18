{
  lib,
  buildPythonPackage,
  fetchPypi,
  poetry-core,
}:

buildPythonPackage rec {
  pname = "krfzf-py";
  version = "0.0.6";

  src = fetchPypi {
    inherit version;
    hash = "sha256-/M9Atu9MLAGmnEdx6tknMJAit2o4Xt971uQ7pb0CBCk=";
    pname = "krfzf_py";
  };

  nativeBuildInputs = [ poetry-core ];
  pyproject = true;
  pythonImportsCheck = [ "fzf" ];

  meta = {
    description = "Pythonic Fzf Wrapper";
    homepage = "https://pypi.org/project/krfzf-py/";
    license = lib.licenses.gpl3Only;
    maintainers = with lib.maintainers; [ doronbehar ];
    downloadPage = "https://github.com/justfoolingaround/fzf.py";
  };
}
