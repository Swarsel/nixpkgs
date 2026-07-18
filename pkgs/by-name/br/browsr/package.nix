{
  lib,
  fetchFromGitHub,
  fetchpatch,
  python3Packages,
  extras ? [ "all" ],
}:

python3Packages.buildPythonApplication (finalAttrs: {
  pname = "browsr";
  version = "1.22.1";

  src = fetchFromGitHub {
    owner = "juftin";
    repo = "browsr";
    tag = "v${finalAttrs.version}";
    hash = "sha256-eISOADs++ZF62qkWbhFZu6JkEVtTytg3q5nbwS2m+8g=";
  };

  patches = [
    # https://github.com/juftin/browsr/pull/55
    (fetchpatch {
      hash = "sha256-vAJ+M6Eg7N2NV7Cb2DWPYqLJIeq/DY1COECEQOnkpXE=";
      name = "textual-6-compat.patch";
      url = "https://github.com/juftin/browsr/commit/ab958ac982e14e836a0e44080a53c920ad50b256.patch";
    })
  ];

  nativeCheckInputs = with python3Packages; [
    pytest-cov-stub
    pytest-textual-snapshot
    pytestCheckHook
  ];

  build-system = with python3Packages; [
    hatchling
  ];

  dependencies =
    with python3Packages;
    [
      art
      click
      pandas
      pillow
      pymupdf
      pyperclip
      rich
      rich-click
      rich-pixels
      textual
      textual-universal-directorytree
    ]
    ++ lib.flatten (lib.attrVals extras finalAttrs.passthru.optional-dependencies);

  disabledTests = [
    # Tests require internet access
    "test_github_screenshot"
    "test_github_screenshot_license"
    "test_textual_app_context_path_github"
    "test_mkdocs_screenshot"
  ];

  optional-dependencies = with python3Packages; {
    all = [
      pyarrow
      textual-universal-directorytree.optional-dependencies.remote
    ];

    parquet = [
      pyarrow
    ];

    remote = [
      textual-universal-directorytree.optional-dependencies.remote
    ];
  };

  pyproject = true;

  pythonImportsCheck = [
    "browsr"
  ];

  pythonRelaxDeps = [
    "art"
    "click"
    "pandas"
    "pymupdf"
    "pyperclip"
    "rich-click"
    "rich-pixels"
    "rich"
    "textual"
    "universal-pathlib"
  ];

  meta = {
    description = "File explorer in your terminal";
    homepage = "https://juftin.com/browsr";
    changelog = "https://github.com/juftin/browsr/releases/tag/${finalAttrs.src.tag}";
    license = lib.licenses.mit;
    maintainers = [ ];
    mainProgram = "browsr";
  };
})
