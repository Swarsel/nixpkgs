{
  lib,
  stdenv,
  buildPythonPackage,
  # dependencies
  fsspec,
  # tests
  gradio,
  hatch-fancy-pypi-readme,
  hatch-requirements-txt,
  # build-system
  hatchling,
  httpx,
  huggingface-hub,
  jq,
  packaging,
  pydub,
  pytest-asyncio,
  pytestCheckHook,
  requests,
  rich,
  safehttpx,
  tomlkit,
  typing-extensions,
  websockets,
  writableTmpDirAsHomeHook,
}:

buildPythonPackage (finalAttrs: {
  # no tests on pypi
  # they've stopped tagging "gradio_client@.*" and "@gradio/client@.*" tags on github
  inherit (gradio) src;
  pname = "gradio-client";
  version = "2.5.0";

  # Because we set sourceRoot above, the folders "client/python"
  # don't exist, as far as this is concerned.
  postPatch = ''
    substituteInPlace test/conftest.py \
      --replace-fail 'from client.python.test import media_data' 'import media_data'
  '';

  nativeBuildInputs = [
    jq
  ];

  preConfigure = ''
    # sanity check
    if [[ "$(jq <gradio_client/package.json .version -r)" != "$version" ]]; then
      echo >&2 "ERROR: version mismatch with package.json:"
      echo >&2 "version = $version"
      (set -x; cat >&2 gradio_client/package.json)
      false
    fi
  '';

  nativeCheckInputs = [
    gradio.sans-reverse-dependencies
    pydub
    pytest-asyncio
    pytestCheckHook
    requests
    rich
    safehttpx
    tomlkit
    writableTmpDirAsHomeHook
  ];

  # Add a pytest hook skipping tests that access network, marking them as "Expected fail" (xfail).
  preCheck = ''
    cat ${./conftest-skip-network-errors.py} >> test/conftest.py
  '';

  postInstall = ''
    mkdir -p $out/lib/gradio
    cp -r ../../gradio/media_assets $out/lib/gradio
  '';

  __darwinAllowLocalNetworking = true;

  build-system = [
    hatchling
    hatch-requirements-txt
    hatch-fancy-pypi-readme
  ];

  dependencies = [
    fsspec
    httpx
    huggingface-hub
    packaging
    typing-extensions
    websockets
  ];

  disabledTestMarks = [
    "flaky"
  ];

  disabledTests = lib.optionals stdenv.hostPlatform.isDarwin [
    # flaky: OSError: Cannot find empty port in range: 7860-7959
    "test_layout_components_in_output"
    "test_layout_and_state_components_in_output"
    "test_upstream_exceptions"
    "test_httpx_kwargs"
  ];

  # ensuring we don't propagate this intermediate build
  disallowedReferences = [ gradio.sans-reverse-dependencies ];

  enabledTestPaths = [
    "test/"
  ];

  pyproject = true;
  pythonImportsCheck = [ "gradio_client" ];
  sourceRoot = "${finalAttrs.src.name}/client/python";

  passthru = {
    inherit (gradio) updateScript;

    # Cyclic dependencies are fun!
    # overridePythonAttrs is not available in finalAttrs.finalPackage
    sans-reverse-dependencies = finalAttrs.finalPackage.overrideAttrs (old: {
      pname = old.pname + "-sans-reverse-dependencies";
      doCheck = false;
      preCheck = "";
      # we aggressively remove all checkPhase related attrs
      # to save on rebuilds during bumps
      doInstallCheck = false;
      disabledTestMarks = [ ];
      disabledTests = [ ];
      dontCheckRuntimeDeps = true;
      enabledTestPaths = [ ];
      pythonImportsCheck = null;
    });
  };

  meta = {
    description = "Lightweight library to use any Gradio app as an API";
    homepage = "https://www.gradio.app/";
    changelog = "https://github.com/gradio-app/gradio/blob/${finalAttrs.src.tag}/client/python/gradio_client/CHANGELOG.md";
    license = lib.licenses.asl20;
    maintainers = with lib.maintainers; [ pbsds ];
    downloadPage = "https://github.com/gradio-app/gradio/tree/main/client/python";
  };
})
