{
  lib,
  fetchFromGitHub,
  ffmpeg,
  python3Packages,
  versionCheckHook,
}:

python3Packages.buildPythonApplication (finalAttrs: {
  pname = "vcsi";
  version = "7.0.16";

  src = fetchFromGitHub {
    owner = "amietn";
    repo = "vcsi";
    tag = "v${finalAttrs.version}";
    hash = "sha256-I0o6GX/TNMfU+rQtSqReblRplXPynPF6m2zg0YokmtI=";
  };

  nativeCheckInputs = [
    versionCheckHook
  ]
  ++ (with python3Packages; [
    pytestCheckHook
  ]);

  build-system = with python3Packages; [
    poetry-core
  ];

  dependencies = with python3Packages; [
    jinja2
    numpy
    parsedatetime
    pillow
    texttable
  ];

  makeWrapperArgs = [ "--prefix PATH : ${lib.makeBinPath [ ffmpeg ]}" ];
  pyproject = true;
  pythonImportsCheck = [ "vcsi" ];

  pythonRelaxDeps = [
    "numpy"
    "pillow"
  ];

  meta = {
    description = "Create video contact sheets";
    homepage = "https://github.com/amietn/vcsi";
    changelog = "https://github.com/amietn/vcsi/releases/tag/v${finalAttrs.version}";
    license = lib.licenses.mit;

    maintainers = with lib.maintainers; [
      dandellion
      zopieux
    ];

    mainProgram = "vcsi";
  };
})
