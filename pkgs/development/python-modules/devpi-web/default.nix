{
  lib,
  stdenv,
  fetchFromGitHub,
  # dependencies
  attrs,
  beautifulsoup4,
  buildPythonPackage,
  defusedxml,
  devpi-common,
  devpi-server,
  docutils,
  gitUpdater,
  packaging-legacy,
  pygments,
  pyramid,
  pyramid-chameleon,
  pytest-cov-stub,
  # tests
  pytestCheckHook,
  readme-renderer,
  setuptools,
  tomli,
  webtest,
  whoosh,
}:

buildPythonPackage (finalAttrs: {
  pname = "devpi-web";
  version = "5.1.0";

  src = fetchFromGitHub {
    owner = "devpi";
    repo = "devpi";
    tag = "web-${finalAttrs.version}";
    hash = "sha256-7uYHkrACVRaSqhCflbN3TrGtAnw7ifdkiiLnuGd8bnw=";
  };

  postPatch = ''
    substituteInPlace pyproject.toml \
      --replace-fail ', "setuptools_changelog_shortener"' ""
  '';

  nativeCheckInputs = [
    pytestCheckHook
    pytest-cov-stub
    packaging-legacy
    webtest
  ];

  build-system = [ setuptools ];

  dependencies = [
    attrs
    beautifulsoup4
    defusedxml
    devpi-common
    devpi-server
    docutils
    pygments
    pyramid
    pyramid-chameleon
    readme-renderer
    tomli
    whoosh
  ]
  ++ readme-renderer.optional-dependencies.md;

  disabledTests = lib.optionals stdenv.hostPlatform.isDarwin [
    # https://github.com/devpi/devpi/issues/1114
    "test_dont_index_deleted_mirror"
  ];

  pyproject = true;
  pythonImportsCheck = [ "devpi_web" ];
  sourceRoot = "${finalAttrs.src.name}/web";

  # devpi uses a monorepo for server, common, client and web
  passthru = {
    # bulk updater selects wrong tag
    skipBulkUpdate = true;

    updateScript = gitUpdater {
      # devpi uses a monorepo for server, common, client and web
      rev-prefix = "web-";
    };
  };

  meta = {
    description = "Web view for devpi-server";
    homepage = "https://github.com/devpi/devpi";
    changelog = "https://github.com/devpi/devpi/blob/${finalAttrs.src.tag}/common/CHANGELOG";
    license = lib.licenses.mit;

    maintainers = with lib.maintainers; [
      confus
    ];
  };
})
