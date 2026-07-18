{
  lib,
  fetchFromGitLab,
  buildPythonPackage,
  hatchling,
  pytestCheckHook,
  sybil,
}:

buildPythonPackage rec {
  pname = "atpublic";
  version = "5.0";

  src = fetchFromGitLab {
    owner = "warsaw";
    repo = "public";
    tag = version;
    hash = "sha256-cqum+4hREu0jO9iFoUUzfzn597BoMAhG+aanwnh8hb8=";
  };

  nativeCheckInputs = [
    pytestCheckHook
    sybil
  ];

  build-system = [ hatchling ];
  pyproject = true;
  pythonImportsCheck = [ "public" ];

  meta = {
    description = "Python decorator and function which populates a module's __all__ and globals";

    longDescription = ''
      This is a very simple decorator and function which populates a module's
      __all__ and optionally the module globals.
    '';

    homepage = "https://public.readthedocs.io/";
    changelog = "https://gitlab.com/warsaw/public/-/blob/${version}/docs/NEWS.rst";
    license = lib.licenses.asl20;
    maintainers = with lib.maintainers; [ eadwu ];
  };
}
