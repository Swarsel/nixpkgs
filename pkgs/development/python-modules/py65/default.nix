{
  lib,
  fetchFromGitHub,
  buildPythonPackage,
  setuptools,
  unittestCheckHook,
}:

buildPythonPackage (finalAttrs: {
  pname = "py65";
  version = "1.2.0";

  src = fetchFromGitHub {
    owner = "mnaberez";
    repo = "py65";
    tag = finalAttrs.version;
    hash = "sha256-BMX+sMPx/YBFA4NFkaY0rl0EPicGHgb6xXVvLEIdllA=";
  };

  nativeCheckInputs = [ unittestCheckHook ];
  build-system = [ setuptools ];
  pyproject = true;

  meta = {
    description = "Emulate 6502-based microcomputer systems in Python";

    longDescription = ''
      Py65 includes a program called Py65Mon that functions as a machine
      language monitor. This kind of program is sometimes also called a
      debugger. Py65Mon provides a command line with many convenient commands
      for interacting with the simulated 6502-based system.
    '';

    homepage = "https://github.com/mnaberez/py65";
    changelog = "https://github.com/mnaberez/py65/blob/${finalAttrs.src.rev}/CHANGES.txt";
    license = lib.licenses.bsd3;

    maintainers = with lib.maintainers; [
      tomasajt
    ];

    mainProgram = "py65mon";
  };
})
