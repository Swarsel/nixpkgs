{
  lib,
  fetchFromGitHub,
  buildPythonPackage,
  flit-core,
  requests,
  sphinx,
}:

buildPythonPackage rec {
  pname = "sphinxcontrib-youtube";
  version = "1.5.0";

  src = fetchFromGitHub {
    owner = "sphinx-contrib";
    repo = "youtube";
    tag = "v${version}";
    hash = "sha256-vzF1SC4fUIeR0OYesOq60eWjlX+N+YYA/h7mNfxWEtk=";
  };

  nativeBuildInputs = [ flit-core ];

  propagatedBuildInputs = [
    sphinx
    requests
  ];

  # tests require internet access
  doCheck = false;
  pyproject = true;
  pythonImportsCheck = [ "sphinxcontrib.youtube" ];
  pythonNamespaces = [ "sphinxcontrib" ];

  meta = {
    description = "Youtube extension for Sphinx";
    homepage = "https://github.com/sphinx-contrib/youtube";
    license = lib.licenses.bsd3;
    maintainers = with lib.maintainers; [ gador ];
  };
}
