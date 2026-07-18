{
  lib,
  fetchFromGitHub,
  buildPythonPackage,
  setuptools,
}:

buildPythonPackage (finalAttrs: {
  pname = "pbar";
  version = "2.2.1";

  src = fetchFromGitHub {
    owner = "darvil82";
    repo = "PBar";
    tag = "v${finalAttrs.version}";
    hash = "sha256-FsEjfusk8isOD52xkjndGQdVC8Vc7N3spLLWQTi3Svc=";
  };

  build-system = [ setuptools ];
  pyproject = true;
  pythonImportsCheck = [ "pbar" ];

  meta = {
    description = "Display customizable progress bars on the terminal easily";
    homepage = "https://darvil82.github.io/PBar";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ sigmanificient ];
  };
})
