{
  lib,
  stdenv,
  fetchFromGitHub,
  buildPythonPackage,
  glean-parser,
  pytest-localserver,
  pytestCheckHook,
  rustPlatform,
  semver,
  setuptools,
}:

buildPythonPackage rec {
  pname = "glean-sdk";
  version = "64.0.0";

  src = fetchFromGitHub {
    owner = "mozilla";
    repo = "glean";
    rev = "v${version}";
    hash = "sha256-6UAZkVBxFJ1CWRn9enCLBBidIugAtxP7stbYlhh1ArA=";
  };

  nativeCheckInputs = [
    pytest-localserver
    pytestCheckHook
  ];

  build-system = [
    rustPlatform.cargoSetupHook
    rustPlatform.maturinBuildHook
    setuptools
  ];

  cargoDeps = rustPlatform.fetchCargoVendor {
    inherit pname version src;
    hash = "sha256-Ppc+6ex3yLC4xuhbZGZDKLqxDjSdGpgrLDpbbbqMgPY=";
  };

  dependencies = [
    glean-parser
    semver
  ];

  disabledTests = [
    # RuntimeError: No ping received.
    "test_client_activity_api"
    "test_flipping_upload_enabled_respects_order_of_events"
    # A warning causes this test to fail
    "test_get_language_tag_reports_the_tag_for_the_default_locale"
  ];

  enabledTestPaths = [ "glean-core/python/tests" ];
  pyproject = true;
  pythonImportsCheck = [ "glean" ];

  meta = {
    description = "Telemetry client libraries and are a part of the Glean project";
    homepage = "https://mozilla.github.io/glean/book/index.html";
    license = lib.licenses.mpl20;
    broken = stdenv.hostPlatform.isDarwin;
  };
}
