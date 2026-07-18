{
  lib,
  fetchFromGitHub,
  buildPythonPackage,
  cppy,
  pytestCheckHook,
  setuptools-scm,
}:

buildPythonPackage rec {
  pname = "atom";
  version = "0.12.1";

  src = fetchFromGitHub {
    owner = "nucleic";
    repo = "atom";
    tag = version;
    hash = "sha256-XFJujJrxubtdCLTr1oaM7h0LNS1Ep08f8+1tRzARBqs=";
  };

  nativeBuildInputs = [ setuptools-scm ];
  buildInputs = [ cppy ];
  nativeCheckInputs = [ pytestCheckHook ];

  preCheck = ''
    rm -rf atom
  '';

  pyproject = true;
  pythonImportsCheck = [ "atom.api" ];

  meta = {
    description = "Memory efficient Python objects";
    homepage = "https://github.com/nucleic/atom";
    changelog = "https://github.com/nucleic/atom/releases/tag/${version}";
    license = lib.licenses.bsd3;
  };
}
