{
  lib,
  fetchFromGitHub,
  beets-audible,
  # nativeBuildInputs
  beets-minimal,
  buildPythonPackage,
  mediafile,
  # tests
  pytestCheckHook,
  reflink,
  toml,
  typeguard,
  # build-system
  uv-build,
  writableTmpDirAsHomeHook,
}:

buildPythonPackage (finalAttrs: {
  pname = "beets-filetote";
  version = "1.3.6";

  src = fetchFromGitHub {
    owner = "gtronset";
    repo = "beets-filetote";
    tag = "v${finalAttrs.version}";
    hash = "sha256-ZrF9Z3Eaem8ZzNJgQoW45MvsNOCoLsd7l/yLQ2pldR0=";
  };

  # https://github.com/gtronset/beets-filetote/issues/328
  postPatch = ''
    substituteInPlace pyproject.toml --replace-fail "uv_build>=0.11.21,<0.12" "uv-build"
  '';

  nativeBuildInputs = [
    beets-minimal
  ];

  nativeCheckInputs = [
    pytestCheckHook
    beets-audible
    mediafile
    reflink
    toml
    typeguard
    writableTmpDirAsHomeHook
  ];

  build-system = [
    uv-build
  ];

  dependencies = [
    mediafile
  ];

  disabledTestPaths = [
    # Tests fail for Beets 2.12.x, see:
    # https://github.com/gtronset/beets-filetote/issues/328
    "tests/test_exclude.py::TestExclude::test_exclude_strseq_of_filenames_by_string"
    "tests/test_exclude.py::TestExclude::test_exclude_strseq_of_filenames_by_list"
    "tests/test_printignored.py::TestPrintIgnored::test_print_ignored"
  ];

  pyproject = true;

  meta = {
    inherit (beets-minimal.meta) platforms;
    description = "Beets plugin to move non-music files during the import process";
    homepage = "https://github.com/gtronset/beets-filetote";
    changelog = "https://github.com/gtronset/beets-filetote/blob/${finalAttrs.src.tag}/CHANGELOG.md";
    license = lib.licenses.mit;

    maintainers = with lib.maintainers; [
      dansbandit
      returntoreality
    ];
  };
})
