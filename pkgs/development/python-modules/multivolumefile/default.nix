{
  lib,
  buildPythonPackage,
  fetchFromCodeberg,
  hypothesis,
  pytest-timeout,
  pytestCheckHook,
  setuptools,
  setuptools-scm,
}:

buildPythonPackage rec {
  pname = "multivolumefile";
  version = "0.2.3";

  src = fetchFromCodeberg {
    owner = "miurahr";
    repo = "multivolume";
    tag = "v${version}";
    hash = "sha256-7gjfF7biQZOcph2dfwi2ouDn/uIYik/KBQ0k6u5Ne+Q=";
  };

  postPatch =
    # Fix typo: `tools` -> `tool`
    # upstream PR: https://codeberg.org/miurahr/multivolume/pulls/9
    ''
      substituteInPlace pyproject.toml \
        --replace-fail 'tools.setuptools_scm' 'tool.setuptools_scm'
    '';

  nativeCheckInputs = [
    hypothesis
    pytest-timeout
    pytestCheckHook
  ];

  build-system = [
    setuptools
    setuptools-scm
  ];

  pyproject = true;

  pythonImportsCheck = [
    "multivolumefile"
  ];

  meta = {
    description = "Library to provide a file-object wrapping multiple files as virtually like as a single file";
    homepage = "https://codeberg.org/miurahr/multivolume";
    changelog = "https://codeberg.org/miurahr/multivolume/src/tag/v${version}/Changelog.rst#v${version}";
    license = lib.licenses.gpl2Plus;

    maintainers = with lib.maintainers; [
      pitkling
      PopeRigby
    ];
  };
}
