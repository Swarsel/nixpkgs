{
  attrs,
  buildPythonPackage,
  click,
  gprof2dot,
  html5lib,
  jinja2,
  memory-profiler,
  psutil,
  pytestCheckHook,
  setuptools,
  textx,
  textx-data-dsl,
  textx-example-project,
  textx-flow-codegen,
  textx-flow-dsl,
  textx-types-dsl,
}:

buildPythonPackage {
  inherit (textx) version;
  pname = "textx-tests";

  nativeCheckInputs = [
    attrs
    click
    gprof2dot
    html5lib
    jinja2
    memory-profiler
    psutil
    pytestCheckHook
    setuptools
    textx-data-dsl
    textx-example-project
    textx-flow-codegen
    textx-flow-dsl
    textx-types-dsl
  ];

  disabledTests = [
    "test_examples" # assertion error: 0 == 12
  ];

  dontBuild = true;
  dontInstall = true;
  enabledTestPaths = [ "tests/functional" ];
  pyproject = false;
  srcs = textx.testout;

  meta = {
    inherit (textx.meta) license maintainers;
    description = "passthru.tests for textx";
    homepage = textx.homepage + "tree/${textx.version}/" + "tests/";
  };
}
