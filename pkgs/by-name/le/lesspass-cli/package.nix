{
  lib,
  fetchFromGitHub,
  python3,
}:

let
  inherit (python3.pkgs)
    buildPythonApplication
    setuptools
    pytestCheckHook
    mock
    pexpect
    ;
  repo = "lesspass";
in
buildPythonApplication (finalAttrs: {
  pname = "lesspass-cli";
  version = "9.1.9";

  src = fetchFromGitHub {
    owner = repo;
    repo = repo;
    rev = finalAttrs.version;
    sha256 = "126zk248s9r72qk9b8j27yvb8gglw49kazwz0sd69b5kkxvhz2dh";
  };

  nativeCheckInputs = [
    pytestCheckHook
    mock
    pexpect
  ];

  preCheck = ''
    mv lesspass lesspass.hidden  # ensure we're testing against *installed* package

    # some tests are designed to run against code in the source directory - adapt to run against
    # *installed* code
    substituteInPlace tests/test_functional.py tests/test_interaction.py \
      --replace-fail "lesspass/core.py" "-m lesspass.core"
  '';

  build-system = [
    setuptools
  ];

  pyproject = true;
  pythonImportsCheck = [ "lesspass" ];
  sourceRoot = "${finalAttrs.src.name}/cli";

  meta = {
    description = "Stateless password manager";
    homepage = "https://lesspass.com";
    license = lib.licenses.gpl3;
    maintainers = with lib.maintainers; [ jasoncarr ];
    mainProgram = "lesspass";
  };
})
