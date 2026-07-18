{
  lib,
  fetchFromGitHub,
  buildPythonPackage,
  hatchling,
  pytestCheckHook,
  traitlets,
}:

let
  pname = "comm";
  version = "0.2.3";
in
buildPythonPackage {
  inherit pname version;

  src = fetchFromGitHub {
    owner = "ipython";
    repo = "comm";
    tag = "v${version}";
    hash = "sha256-gDggPu2h43lGyovTND9a3o9F2hWppV5uvAJa78JxJCo=";
  };

  nativeBuildInputs = [ hatchling ];
  propagatedBuildInputs = [ traitlets ];
  nativeCheckInputs = [ pytestCheckHook ];
  pyproject = true;

  meta = {
    description = "Jupyter Python Comm implementation, for usage in ipykernel, xeus-python etc";
    homepage = "https://github.com/ipython/comm";
    license = lib.licenses.bsd3;
    maintainers = [ ];
  };
}
