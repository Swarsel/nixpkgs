{
  lib,
  fetchFromGitHub,
  # dependencies
  anyascii,
  beautifulsoup4,
  buildPythonPackage,
  # tests
  callPackage,
  django,
  django-filter,
  django-modelcluster,
  django-taggit,
  django-tasks,
  django-treebeard,
  djangorestframework,
  draftjs-exporter,
  # frontend
  fetchNpmDeps,
  laces,
  modelsearch,
  nodejs,
  npmHooks,
  openpyxl,
  permissionedforms,
  pillow,
  requests,
  # build-system
  setuptools,
  telepath,
  willow,
}:

buildPythonPackage (finalAttrs: {
  pname = "wagtail";
  version = "7.4.2";

  src = fetchFromGitHub {
    owner = "wagtail";
    repo = "wagtail";
    tag = "v${finalAttrs.version}";
    hash = "sha256-6IttzQnASWMDq4fgyrpJj3KrQvO4zMq+0dLTfm8bLzs=";
  };

  nativeBuildInputs = [
    npmHooks.npmConfigHook
    nodejs
  ];

  preBuild = ''
    # upstream only provides a hook for sdists, not wheels
    # https://github.com/wagtail/wagtail/blob/v7.3/setup.py#L22
    npm run build
  '';

  # Tests are in separate derivation because they require a package that depends
  # on wagtail (wagtail-factories)
  doCheck = false;

  build-system = [
    setuptools
  ];

  dependencies = [
    anyascii
    beautifulsoup4
    django
    django-filter
    django-modelcluster
    django-taggit
    django-tasks
    django-treebeard
    djangorestframework
    draftjs-exporter
    laces
    modelsearch
    openpyxl
    permissionedforms
    pillow
    requests
    telepath
    willow
  ]
  ++ willow.optional-dependencies.heif;

  npmDeps = fetchNpmDeps {
    inherit (finalAttrs) src;
    hash = "sha256-Z2VOMqsNIBybJpfYxAq2dkmS2vwd8Yuhu7MCFyqNxdI=";
  };

  pyproject = true;
  pythonImportsCheck = [ "wagtail" ];

  pythonRelaxDeps = [
    "django-tasks"
    "modelsearch"
  ];

  passthru.tests.wagtail = callPackage ./tests.nix { };

  meta = {
    description = "Django content management system focused on flexibility and user experience";
    homepage = "https://github.com/wagtail/wagtail";
    changelog = "https://github.com/wagtail/wagtail/blob/${finalAttrs.src.tag}/CHANGELOG.txt";
    license = lib.licenses.bsd3;
    maintainers = with lib.maintainers; [ sephi ];
    mainProgram = "wagtail";
  };
})
