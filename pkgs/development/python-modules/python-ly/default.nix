{
  lib,
  fetchFromGitHub,
  buildPythonPackage,
  hatchling,
  lxml,
  pytestCheckHook,
  versionCheckHook,
}:

buildPythonPackage (finalAttrs: {
  pname = "python-ly";
  version = "0.9.10";

  src = fetchFromGitHub {
    owner = "frescobaldi";
    repo = "python-ly";
    tag = "v${finalAttrs.version}";
    hash = "sha256-diLg1rU+SmCutW1WJQtMJvpipU+k8GluvAqFfcv1GS4=";
  };

  nativeCheckInputs = [
    lxml
    pytestCheckHook
  ];

  doInstallCheck = true;
  nativeInstallCheckInputs = [ versionCheckHook ];
  build-system = [ hatchling ];
  pyproject = true;
  pythonImportsCheck = [ "ly" ];

  meta = {
    description = "Tool and library for manipulating LilyPond files";

    longDescription = ''
      This package provides a Python library ly containing various
      Python modules to parse, manipulate or create documents in
      LilyPond format.  A command line program ly is also provided
      that can be used to do various manipulations with LilyPond
      files.

      The LilyPond format is a plain text input format that is used by
      the GNU music typesetter [LilyPond](https://lilypond.org).
    '';

    homepage = "https://pypi.org/project/python-ly";
    changelog = "https://github.com/frescobaldi/python-ly/blob/${finalAttrs.src.tag}/CHANGELOG.md";
    license = lib.licenses.gpl3Plus;
    maintainers = with lib.maintainers; [ yiyu ];
    mainProgram = "ly";
  };
})
