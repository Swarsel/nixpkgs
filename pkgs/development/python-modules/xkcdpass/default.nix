{
  lib,
  buildPythonPackage,
  fetchPypi,
  installShellFiles,
  pytestCheckHook,
  setuptools,
}:

buildPythonPackage (finalAttrs: {
  pname = "xkcdpass";
  version = "1.30.0";

  src = fetchPypi {
    inherit (finalAttrs) pname version;
    hash = "sha256-ijprYCVdpA0OXIEkWCgCeMgtLBy5DkivvWd327+HlcM=";
  };

  nativeBuildInputs = [ installShellFiles ];
  nativeCheckInputs = [ pytestCheckHook ];

  postInstall = ''
    installManPage *.?
    install -Dm444 -t $out/share/doc/${finalAttrs.pname} README*
  '';

  build-system = [ setuptools ];

  disabledTests = [
    # AssertionError: 29611 != 5670
    "test_loadwordfile"
  ];

  pyproject = true;
  pythonImportsCheck = [ "xkcdpass" ];

  meta = {
    description = "Generate secure multiword passwords/passphrases, inspired by XKCD";
    homepage = "https://github.com/redacted/XKCD-password-generator";
    license = lib.licenses.bsd3;
    maintainers = with lib.maintainers; [ peterhoeg ];
    mainProgram = "xkcdpass";
  };
})
