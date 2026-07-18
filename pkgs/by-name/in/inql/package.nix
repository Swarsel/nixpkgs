{
  lib,
  fetchFromGitHub,
  python3,
}:

python3.pkgs.buildPythonApplication (finalAttrs: {
  pname = "inql";
  version = "4.0.6";

  src = fetchFromGitHub {
    owner = "doyensec";
    repo = "inql";
    tag = "v${finalAttrs.version}";
    hash = "sha256-DFGJHqdrCmOZn8GdY5SZ1PrOhuIsMLoK+2Fry9WkRiY=";
  };

  postPatch = ''
    # To set the version a full git checkout would be needed
    substituteInPlace setup.py \
      --replace-fail "version=version()," "version='${finalAttrs.version}',"
  '';

  # Project has no tests
  doCheck = false;

  build-system = with python3.pkgs; [
    setuptools
  ];

  dependencies = with python3.pkgs; [
    stickytape
  ];

  pyproject = true;

  pythonImportsCheck = [
    "inql"
  ];

  meta = {
    description = "Security testing tool for GraphQL";
    homepage = "https://github.com/doyensec/inql";
    changelog = "https://github.com/doyensec/inql/releases/tag/v${finalAttrs.version}";
    license = with lib.licenses; [ asl20 ];
    maintainers = with lib.maintainers; [ fab ];
    mainProgram = "inql";
  };
})
