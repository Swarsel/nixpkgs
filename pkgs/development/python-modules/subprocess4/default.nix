{
  lib,
  fetchFromGitHub,
  buildPythonPackage,
  hatchling,
  pytestCheckHook,
}:

buildPythonPackage (finalAttrs: {
  pname = "subprocess4";
  version = "0.1.1";

  src = fetchFromGitHub {
    owner = "JasonGross";
    repo = "subprocess4";
    tag = "v${finalAttrs.version}";
    hash = "sha256-On0mUc5DLktlaVSK/7VcEKRG1dnmYHNRSe149BnoIAk=";
  };

  nativeCheckInputs = [ pytestCheckHook ];

  build-system = [
    hatchling
  ];

  pyproject = true;

  pythonImportsCheck = [
    "subprocess4"
  ];

  meta = {
    description = "Python subprocess wrapper using os.wait4 to get resource usage";
    homepage = "https://github.com/JasonGross/subprocess4";
    changelog = "https://github.com/JasonGross/subprocess4/releases/tag/v${finalAttrs.version}";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ moraxyc ];
    platforms = lib.platforms.unix; # require posix
  };
})
