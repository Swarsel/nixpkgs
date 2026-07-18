{
  lib,
  fetchFromCodeberg,
  nix-update-script,
  python3Packages,
  yt-dlp,
}:

python3Packages.buildPythonApplication (finalAttrs: {
  pname = "gallery-dl";
  version = "1.32.5";

  src = fetchFromCodeberg {
    owner = "mikf";
    repo = "gallery-dl";
    tag = "v${finalAttrs.version}";
    hash = "sha256-6E4PgJ6VWI0c6TyQOZ0siqsMxNNLpymy8/rANWaBVnU=";
  };

  nativeCheckInputs = [ python3Packages.pytestCheckHook ];
  build-system = [ python3Packages.setuptools ];

  dependencies = [
    python3Packages.requests
    python3Packages.pysocks
    yt-dlp
  ];

  disabledTestPaths = [
    # requires network access
    "test/test_results.py"
    "test/test_downloader.py"

    # incompatible with pytestCheckHook
    "test/test_ytdl.py"
  ];

  disabledTests = [
    # requires network access
    "test_init"
  ];

  pyproject = true;
  pythonImportsCheck = [ "gallery_dl" ];
  passthru.updateScript = nix-update-script { };

  meta = {
    description = "Command-line program to download image-galleries and -collections from several image hosting sites";
    homepage = "https://codeberg.org/mikf/gallery-dl";
    changelog = "https://codeberg.org/mikf/gallery-dl/src/tag/v${finalAttrs.version}/CHANGELOG.md";
    license = lib.licenses.gpl2Only;

    maintainers = with lib.maintainers; [
      dawidsowa
      _4evy
    ];

    mainProgram = "gallery-dl";
  };
})
