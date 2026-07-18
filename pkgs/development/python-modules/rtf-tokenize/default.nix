{
  lib,
  fetchFromGitHub,
  buildPythonPackage,
  pytestCheckHook,
  python,
  setuptools,
  versionCheckHook,
  which,
}:

buildPythonPackage (finalAttrs: {
  pname = "rtf-tokenize";
  version = "1.0.1";

  src = fetchFromGitHub {
    owner = "openstenoproject";
    repo = "rtf_tokenize";
    tag = finalAttrs.version;
    hash = "sha256-bM/DFl1mpHgeBItdyA5Tt+Eo9u82Gz+6qwft2h0bM94=";
  };

  nativeCheckInputs = [ pytestCheckHook ];
  doInstallCheck = true;

  nativeInstallCheckInputs = [
    versionCheckHook
    which
  ];

  __structuredAttrs = true;
  build-system = [ setuptools ];

  preInstallCheck = ''
    versionCheckProgram="$(which ls)"
  '';

  pyproject = true;
  pythonImportsCheck = [ "rtf_tokenize" ];
  versionCheckProgramArg = "${placeholder "out"}/${python.sitePackages}";

  meta = {
    description = "Simple RTF tokenizer package for Python";
    homepage = "https://github.com/openstenoproject/rtf_tokenize";
    license = lib.licenses.gpl2Plus; # https://github.com/openstenoproject/rtf_tokenize/issues/1

    maintainers = with lib.maintainers; [
      pandapip1
      ShamrockLee
    ];
  };
})
