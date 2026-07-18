{
  lib,
  fetchFromGitHub,
  python3Packages,
}:

python3Packages.buildPythonApplication (finalAttrs: {
  pname = "replacement";
  version = "0.4.4";

  src = fetchFromGitHub {
    owner = "siriobalmelli";
    repo = "replacement";
    rev = "v${finalAttrs.version}";
    sha256 = "0j4lvn3rx1kqvxcsd8nhc2lgk48jyyl7qffhlkvakhy60f9lymj3";
  };

  nativeCheckInputs = with python3Packages; [
    pytestCheckHook
    sh
  ];

  build-system = with python3Packages; [
    setuptools
  ];

  dependencies = with python3Packages; [
    ruamel-yaml
  ];

  pyproject = true;

  meta = {
    description = "Tool to execute yaml templates and output text";

    longDescription = ''
      Replacement is a python utility
      that parses a yaml template and outputs text.

      A 'template' is a YAML file containing a 'replacement' object.

      A 'replacement' object contains a list of blocks,
      each of which is executed in sequence.

      This tool is useful in generating configuration files,
      static websites and the like.
    '';

    homepage = "https://github.com/siriobalmelli/replacement";
    license = lib.licenses.asl20;
    maintainers = with lib.maintainers; [ siriobalmelli ];
    mainProgram = "replacement";
  };
})
