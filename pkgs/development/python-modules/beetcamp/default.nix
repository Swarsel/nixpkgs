{
  lib,
  fetchFromGitHub,
  beets,
  buildPythonPackage,
  filelock,
  httpx,
  nix-update-script,
  packaging,
  poetry-core,
  pycountry,
  pytest-cov-stub,
  pytestCheckHook,
  rich-tables,
  writableTmpDirAsHomeHook,
}:

buildPythonPackage (finalAttrs: {
  pname = "beetcamp";
  version = "0.24.3";

  src = fetchFromGitHub {
    owner = "snejus";
    repo = "beetcamp";
    tag = finalAttrs.version;
    hash = "sha256-kKFYuTJys4j67+cak2PDmn6z2vNzVitFXIZXy2bClY8=";
  };

  patches = [
    ./remove-git-pytest-option.diff
  ];

  nativeBuildInputs = [
    beets
  ];

  nativeCheckInputs = [
    writableTmpDirAsHomeHook
    pytestCheckHook
    pytest-cov-stub
    rich-tables
    filelock
  ];

  build-system = [
    poetry-core
  ];

  dependencies = [
    httpx
    packaging
    pycountry
  ];

  disabledTests = [
    # AssertionError: assert ''
    "test_get_html"
  ];

  pyproject = true;

  passthru = {
    tests = {
      beets-with-beetcamp = beets.override {
        pluginOverrides = {
          beetcamp = {
            propagatedBuildInputs = [ finalAttrs.finalPackage ];
            enable = true;
          };
        };
      };
    };

    updateScript = nix-update-script { };
  };

  meta = {
    description = "Bandcamp autotagger source for beets (http://beets.io)";
    homepage = "https://github.com/snejus/beetcamp";
    changelog = "https://github.com/snejus/beetcamp/blob/${finalAttrs.version}/CHANGELOG.md";
    license = lib.licenses.gpl2Only;

    maintainers = [
      lib.maintainers._9999years
    ];

    mainProgram = "beetcamp";
  };
})
