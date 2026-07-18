{
  lib,
  fetchFromGitHub,
  buildPythonPackage,
  mdformat,
  poetry-core,
  pytestCheckHook,
}:

buildPythonPackage rec {
  pname = "mdformat-toc";
  version = "0.5.0";

  src = fetchFromGitHub {
    owner = "hukkin";
    repo = "mdformat-toc";
    tag = version;
    hash = "sha256-Rj1lp5Ub+UriOuE896tywN4myovna2RLYO3LRa96FCM=";
  };

  nativeBuildInputs = [ poetry-core ];
  propagatedBuildInputs = [ mdformat ];
  nativeCheckInputs = [ pytestCheckHook ];
  pyproject = true;
  pythonImportsCheck = [ "mdformat_toc" ];

  meta = {
    description = "Mdformat plugin to generate a table of contents";
    homepage = "https://github.com/hukkin/mdformat-toc";
    license = lib.licenses.mit;

    maintainers = with lib.maintainers; [
      aldoborrero
      polarmutex
    ];
  };
}
