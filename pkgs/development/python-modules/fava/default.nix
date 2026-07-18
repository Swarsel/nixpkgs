{
  lib,
  stdenv,
  fetchFromGitHub,
  babel,
  beancount,
  beangulp,
  beanquery,
  buildNpmPackage,
  buildPythonPackage,
  cheroot,
  click,
  fetchpatch2,
  flask,
  flask-babel,
  jinja2,
  markdown2,
  ply,
  pytestCheckHook,
  setuptools-scm,
  simplejson,
  watchfiles,
  werkzeug,
}:
let
  src = buildNpmPackage (finalAttrs: {
    installPhase = ''
      runHook preInstall
      cp -R .. $out
      runHook postInstall
    '';

    makeCacheWritable = true;
    npmDepsHash = "sha256-DQQISV615wZjNbvZwmF/AGJyJJIIs3iBS1tJCNPpT/o=";
    pname = "fava-frontend";

    preBuild = ''
      chmod -R u+w ..
    '';

    sourceRoot = "${finalAttrs.src.name}/frontend";

    src = fetchFromGitHub {
      owner = "beancount";
      repo = "fava";
      tag = "v${finalAttrs.version}";
      hash = "sha256-h4mjZIINR6RLYycGl2RFIEGuPPbJYYSg1TBGlZupCMw=";
    };

    version = "1.30.13";
  });
in
buildPythonPackage {
  inherit (src) version;
  inherit src;
  pname = "fava";

  patches = [
    ./dont-compile-frontend.patch
  ];

  postPatch = ''
    substituteInPlace tests/test_cli.py \
      --replace-fail '"fava"' '"${placeholder "out"}/bin/fava"'
  '';

  env = {
    # Disable some tests when building with beancount2
    SNAPSHOT_IGNORE = lib.versions.major beancount.version == "2";
  };

  nativeCheckInputs = [ pytestCheckHook ];
  # tests/test_cli.py
  __darwinAllowLocalNetworking = true;
  build-system = [ setuptools-scm ];

  dependencies = [
    babel
    beancount
    beangulp
    beanquery
    cheroot
    click
    flask
    flask-babel
    jinja2
    markdown2
    ply
    simplejson
    werkzeug
    watchfiles
  ];

  # flaky, fails only on ci
  disabledTestPaths = lib.optionals stdenv.hostPlatform.isDarwin [ "tests/test_core_watcher.py" ];
  pyproject = true;
  pythonImportsCheck = [ "fava" ];

  meta = {
    description = "Web interface for beancount";
    homepage = "https://beancount.github.io/fava";
    changelog = "https://beancount.github.io/fava/changelog.html";
    license = lib.licenses.mit;

    maintainers = with lib.maintainers; [
      prince213
      sigmanificient
      cbrxyz
    ];

    mainProgram = "fava";
  };
}
