{
  lib,
  fetchFromGitHub,
  python3,
}:

python3.pkgs.buildPythonApplication (finalAttrs: {
  pname = "hstsparser";
  version = "1.2.0";

  src = fetchFromGitHub {
    owner = "thebeanogamer";
    repo = "hstsparser";
    tag = finalAttrs.version;
    hash = "sha256-9ZNBzPa4mFXbao73QukEL56sM/3dg4ElOMXgNGTVh1g=";
  };

  nativeBuildInputs = with python3.pkgs; [
    poetry-core
  ];

  propagatedBuildInputs = with python3.pkgs; [
    prettytable
  ];

  pyproject = true;

  pythonImportsCheck = [
    "hstsparser"
  ];

  meta = {
    description = "Tool to parse Firefox and Chrome HSTS databases into forensic artifacts";
    homepage = "https://github.com/thebeanogamer/hstsparser";
    changelog = "https://github.com/thebeanogamer/hstsparser/releases/tag/${finalAttrs.version}";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ fab ];
    mainProgram = "hstsparser";
  };
})
