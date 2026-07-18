{
  lib,
  fetchFromGitHub,
  # tests
  beautifulsoup4,
  # dependencies
  blinker,
  buildPythonPackage,
  docutils,
  feedgenerator,
  git,
  # native dependencies
  glibcLocales,
  jinja2,
  lxml,
  markdown,
  mock,
  ordered-set,
  pandoc,
  # build-system
  pdm-backend,
  pygments,
  pytest-xdist,
  pytestCheckHook,
  python-dateutil,
  rich,
  typogrify,
  tzdata,
  unidecode,
  watchfiles,
}:

buildPythonPackage rec {
  pname = "pelican";
  version = "4.12.0";

  src = fetchFromGitHub {
    owner = "getpelican";
    repo = "pelican";
    tag = version;
    hash = "sha256-g/wm4ZA4KBMnvpe58ZQ7lTUBF6PywC4IivmBBco4F00=";

    # Remove unicode file names which leads to different checksums on HFS+
    # vs. other filesystems because of unicode normalisation.
    postFetch = ''
      rm -r $out/pelican/tests/output/custom_locale/posts
    '';
  };

  postPatch = ''
    substituteInPlace pelican/tests/test_pelican.py \
      --replace-fail "\"git\"" "'${git}/bin/git'"
  '';

  buildInputs = [
    glibcLocales
    pandoc
    git
    markdown
    typogrify
  ];

  env.LC_ALL = "en_US.UTF-8";

  nativeCheckInputs = [
    beautifulsoup4
    git
    lxml
    mock
    pandoc
    pytest-xdist
    pytestCheckHook
  ];

  postFixup = ''
    patchShebangs $out/bin
  '';

  build-system = [ pdm-backend ];

  dependencies = [
    blinker
    docutils
    feedgenerator
    jinja2
    ordered-set
    pygments
    python-dateutil
    rich
    tzdata
    unidecode
    watchfiles
  ];

  disabledTests = [
    # AssertionError
    "test_basic_generation_works"
    "test_custom_generation_works"
    "test_custom_locale_generation_works"
  ];

  # We only want to patch shebangs in /bin, and not those
  # of the project scripts that are created by Pelican.
  # See https://github.com/NixOS/nixpkgs/issues/30116
  dontPatchShebangs = true;

  optional-dependencies = {
    markdown = [ markdown ];
  };

  pyproject = true;
  pythonImportsCheck = [ "pelican" ];
  pythonRelaxDeps = [ "pygments" ];

  meta = {
    description = "Static site generator that requires no database or server-side logic";
    homepage = "https://getpelican.com/";
    changelog = "https://github.com/getpelican/pelican/blob/${src.tag}/docs/changelog.rst";
    license = lib.licenses.agpl3Only;

    maintainers = with lib.maintainers; [
      prikhi
    ];
  };
}
