{
  lib,
  fetchFromGitHub,
  python3Packages,
}:

python3Packages.buildPythonApplication (finalAttrs: {
  pname = "norminette";
  version = "3.3.59";

  src = fetchFromGitHub {
    owner = "42School";
    repo = "norminette";
    tag = finalAttrs.version;
    hash = "sha256-XPaMQCziL9/h+AHx6I6MIRAlzscWvOTkxUP9dMI4y0o=";
  };

  nativeCheckInputs = with python3Packages; [
    pytestCheckHook
  ];

  build-system = with python3Packages; [
    poetry-core
  ];

  pyproject = true;
  pythonImportsCheck = [ "norminette" ];

  pythonRemoveDeps = [
    # Can be removed once https://github.com/42school/norminette/issues/565 is addressed
    "argparse"
  ];

  meta = {
    description = "Open source norminette to apply 42's norme to C files";
    homepage = "https://github.com/42School/norminette";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ wegank ];
    mainProgram = "norminette";
  };
})
