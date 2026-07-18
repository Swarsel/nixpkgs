{
  lib,
  fetchFromGitHub,
  buildNpmPackage,
  buildPythonPackage,
  # tests
  dj-database-url,
  # dependencies
  django,
  django-rq,
  # build-system
  flit-core,
  freezegun,
  # optional-dependencies
  google-cloud-translate,
  polib,
  python,
  typing-extensions,
  wagtail,
  wagtail-modeladmin,
}:
let
  pname = "wagtail-localize";

  version = "1.13.1";

  src = fetchFromGitHub {
    owner = "wagtail";
    repo = "wagtail-localize";
    tag = "v${version}";
    hash = "sha256-iJwX/N8/aaAjinU1htVasp88fuuZCOomVPgJ1Ymxre4=";
  };

  assets = buildNpmPackage {
    inherit version src;
    pname = "${pname}-assets";
    npmDepsHash = "sha256-mLZaa3BBvbbgaSgZhsdUVPRXR6X5xy/sWRiOXnzV2cQ=";

    installPhase = ''
      runHook preInstall

      mkdir $out

      for static_dir in wagtail_localize/static; do
        cp --parents -r $static_dir $out
      done

      runHook postInstall
    '';

    NODE_OPTIONS = "--openssl-legacy-provider";
  };
in

buildPythonPackage rec {
  inherit pname version src;
  # See https://github.com/wagtail/wagtail-localize/issues/922
  patches = [ ./failing-test.patch ];

  preBuild = ''
    cp -r ${assets}/wagtail_localize .
  '';

  nativeCheckInputs = [
    dj-database-url
    django-rq
    freezegun
    google-cloud-translate
  ];

  checkPhase = ''
    runHook preCheck

    ${python.interpreter} testmanage.py test

    runHook postCheck
  '';

  build-system = [ flit-core ];

  dependencies = [
    django
    polib
    typing-extensions
    wagtail
    wagtail-modeladmin
  ];

  optional-dependencies = {
    google = [ google-cloud-translate ];
  };

  pyproject = true;

  meta = {
    description = "Translation plugin for Wagtail CMS";
    homepage = "https://github.com/wagtail/wagtail-localize";
    changelog = "https://github.com/wagtail/wagtail-localize/blob/${src.tag}/CHANGELOG.md";
    license = lib.licenses.bsd3;
    maintainers = with lib.maintainers; [ sephi ];
  };
}
