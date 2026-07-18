{
  lib,
  fetchFromGitHub,

  python3Packages,
}:

python3Packages.buildPythonApplication (finalAttrs: {
  pname = "xacro";
  version = "2.1.1";

  src = fetchFromGitHub {
    owner = "ros";
    repo = "xacro";
    tag = finalAttrs.version;
    hash = "sha256-xYFwVM5qpy2/cYKtcf/v5sSlL2e/taIC4IQ48ZiRxiw=";
  };

  strictDeps = true;
  __structuredAttrs = true;

  build-system = [
    python3Packages.setuptools
    python3Packages.setuptools-scm
  ];

  dependencies = [
    python3Packages.pyyaml
  ];

  pyproject = true;
  pythonImportsCheck = [ "xacro" ];

  meta = {
    description = "Xacro is an XML macro language. With xacro, you can construct shorter and more readable XML files by using macros that expand to larger XML expressions";
    homepage = "https://github.com/ros/xacro";
    changelog = "https://github.com/ros/xacro/blob/${finalAttrs.src.rev}/CHANGELOG.rst";
    license = lib.licenses.bsd3;
    maintainers = with lib.maintainers; [ nim65s ];
    mainProgram = "xacro";
  };
})
