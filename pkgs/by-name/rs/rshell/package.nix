{
  lib,
  fetchPypi,
  python3Packages,
  versionCheckHook,
}:

python3Packages.buildPythonApplication (finalAttrs: {
  pname = "rshell";
  version = "0.0.36";

  src = fetchPypi {
    inherit (finalAttrs) pname version;
    hash = "sha256-SmbYNSB0eVUOWdDdPoMAPQTE7KeKTkklD4h+0t1LC/U=";
  };

  nativeCheckInputs = [ versionCheckHook ];
  __structuredAttrs = true;

  build-system = [
    python3Packages.setuptools
  ];

  dependencies = with python3Packages; [
    pyserial
    pyudev
  ];

  pyproject = true;

  meta = {
    description = "Remote Shell for MicroPython";
    homepage = "https://github.com/dhylands/rshell";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ c0deaddict ];
    mainProgram = "rshell";
  };
})
