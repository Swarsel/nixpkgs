{
  lib,
  fetchFromGitHub,
  python3Packages,
  # tests
  versionCheckHook,
  writableTmpDirAsHomeHook,
}:
python3Packages.buildPythonApplication (finalAttrs: {
  pname = "inventree-part-import";
  version = "1.9.2";

  src = fetchFromGitHub {
    owner = "30350n";
    repo = "inventree-part-import";
    tag = finalAttrs.version;
    hash = "sha256-EzPojJNFTptqxIeGuqbA2ZlcTmj1BI6IUcOeld64apk=";
  };

  # Tests have not been updated to use the new class name
  postPatch = ''
    substituteInPlace tests/test_cli.py \
      --replace-fail "ParameterTemplate" "PartParameterTemplate"
  '';

  nativeCheckInputs = [
    versionCheckHook
    writableTmpDirAsHomeHook
  ]
  ++ (with python3Packages; [
    pytestCheckHook
  ]);

  __structuredAttrs = true;

  build-system = with python3Packages; [
    hatchling
  ];

  dependencies = with python3Packages; [
    beautifulsoup4
    browser-cookie3
    click
    cutie
    error-helper
    fake-useragent
    inventree
    isocodes
    mouser
    platformdirs
    pyyaml
    requests
    requests-oauthlib
    tablib
    thefuzz
  ];

  disabledTests = [
    # Requires access to inventree server
    "setup_categories"
  ];

  pyproject = true;
  pytestImportsCheck = [ "inventree_part_import" ];

  meta = {
    description = "CLI to import parts from suppliers like DigiKey, LCSC, Mouser, etc. to InvenTree";
    homepage = "https://github.com/30350n/inventree-part-import";
    changelog = "https://github.com/30350n/inventree-part-import/releases/tag/${finalAttrs.src.tag}";
    license = lib.licenses.mit;

    maintainers = with lib.maintainers; [
      gigahawk
    ];

    mainProgram = "inventree-part-import";
  };
})
