{
  lib,
  stdenv,
  fetchFromGitHub,
  buildPythonPackage,
  pytestCheckHook,
  setuptools,
}:

buildPythonPackage rec {
  pname = "send2trash";
  version = "2.1.0";

  src = fetchFromGitHub {
    owner = "hsoft";
    repo = "send2trash";
    tag = version;
    hash = "sha256-dBILb1tz3/X3/MnhSKujVX9pMFrTAyntQ+GQsscklQU=";
  };

  nativeBuildInputs = [ setuptools ];
  doCheck = !stdenv.hostPlatform.isDarwin;
  nativeCheckInputs = [ pytestCheckHook ];

  preCheck = ''
    export HOME=$TMPDIR
  '';

  pyproject = true;

  meta = {
    description = "Send file to trash natively under macOS, Windows and Linux";
    homepage = "https://github.com/hsoft/send2trash";
    changelog = "https://github.com/arsenetar/send2trash/blob/${src.tag}/CHANGES.rst";
    license = lib.licenses.bsd3;
    maintainers = [ ];
    mainProgram = "send2trash";
  };
}
