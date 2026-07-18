{
  lib,
  fetchFromGitHub,
  buildPythonPackage,
  fetchpatch,
  # nativeBuildInputs for GUI
  gobject-introspection,
  gtk4,
  lxml,
  prompt-toolkit,
  # for GUI only
  pygobject3,
  # dependencies (required for most functionality)
  pyicu,
  # build-system
  setuptools,
  tqdm,
  # tests
  versionCheckHook,
  wrapGAppsHook4,
  enableCmd ? false,
  enableGui ? false,
}:

buildPythonPackage (finalAttrs: {
  pname = "pyglossary";
  version = "5.4.2";

  src = fetchFromGitHub {
    owner = "ilius";
    repo = "pyglossary";
    tag = finalAttrs.version;
    hash = "sha256-Q2QS/Kg4iN1WMFTADfoqN9UC9da/5Bcp7ZjiZ5V3InM=";
  };

  buildInputs = lib.optionals enableGui [
    gtk4
  ];

  # Many issues with the tests: They require `cd tests` in `preCheck`; Some of
  # them depend upon files in `tests/deprecated`; Even with workarounds to
  # these 2 issues, many tests require network access. We don't enable the
  # tests by not adding pytestCheckHook to this list.
  nativeCheckInputs = [
    versionCheckHook
  ];

  build-system = [
    setuptools
  ]
  ++ lib.optionals enableGui [
    gobject-introspection
    wrapGAppsHook4
  ];

  dependencies = [
    pyicu
    lxml
  ]
  ++ lib.optionals enableGui [
    pygobject3
  ]
  ++ lib.optionals enableCmd [
    prompt-toolkit
    tqdm
  ];

  pyproject = true;

  pythonImportsCheck = [
    "pyglossary"
  ];

  meta = {
    description = "Tool for converting dictionary files aka glossaries. Mainly to help use our offline glossaries in any Open Source dictionary we like on any operating system / device";
    homepage = "https://github.com/ilius/pyglossary";
    license = lib.licenses.gpl3Only;
    maintainers = with lib.maintainers; [ doronbehar ];
    mainProgram = "pyglossary";
  };
})
