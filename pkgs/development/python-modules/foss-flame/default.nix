{
  lib,
  fetchFromGitHub,
  buildPythonPackage,
  # dependencies
  jsonschema,
  license-expression,
  osadl-matrix,
  # tests
  pytestCheckHook,
  pyyaml,
  # build-system
  setuptools,
  spdx-license-list,
}:

buildPythonPackage (finalAttrs: {
  pname = "foss-flame";
  version = "0.21.8";

  src = fetchFromGitHub {
    owner = "hesa";
    repo = "foss-licenses";
    tag = finalAttrs.version;
    hash = "sha256-vtiwY5l9zlNKQdoO3NSOG+9U1chqD5tvzBE20xSnGPA=";

    postFetch = ''
      # We have `CONSIDERATIONS.md` and `considerations.md` with almost the
      # same contents, but because Darwin is case-insensitive, having both
      # files results in a conflict, and therefore different source hashes than
      # other platforms.
      find $out -iname "considerations.md" -delete
    '';
  };

  nativeCheckInputs = [
    pytestCheckHook
  ];

  preCheck = ''
    ln -s ../tests .
  '';

  __structuredAttrs = true;

  build-system = [
    setuptools
  ];

  dependencies = [
    jsonschema
    license-expression
    osadl-matrix
    pyyaml
    spdx-license-list
  ];

  pyproject = true;

  # Upstream setup.cfg has addopts, requiring pytest-{cov,forked,random-order}.
  # Clearing it is simpler than replicating those plugins, especially since
  # they only affect how tests run.
  pytestFlags = [
    "--override-ini=addopts="
  ];

  pythonImportsCheck = [
    "flame"
  ];

  sourceRoot = "${finalAttrs.src.name}/python";

  meta = {
    description = "License meta data: data and python module/cli";
    homepage = "https://github.com/hesa/foss-licenses";
    changelog = "https://github.com/hesa/foss-licenses/releases/tag/${finalAttrs.src.tag}";

    license = with lib.licenses; [
      bsd2
      cc-by-40
      gpl3Plus
    ];

    maintainers = with lib.maintainers; [ eljamm ];
    mainProgram = "flame";
    teams = with lib.teams; [ ngi ];
  };
})
