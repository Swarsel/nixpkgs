{
  lib,
  fetchFromGitHub,
  # optional-dependencies
  aiohttp,
  # dependencies
  appdirs,
  # buildInputs
  armips,
  buildPythonPackage,
  dungeon-eos,
  explorerscript,
  gql,
  graphql-core,
  lru-dict,
  ndspy,
  # tests
  parameterized,
  pillow,
  pmdsky-debug-py,
  pytestCheckHook,
  pyyaml,
  range-typed-integers,
  # build-system
  setuptools,
  skytemple-rust,
  xmldiff,
}:

buildPythonPackage (finalAttrs: {
  pname = "skytemple-files";
  version = "1.8.5";

  src = fetchFromGitHub {
    owner = "SkyTemple";
    repo = "skytemple-files";
    tag = finalAttrs.version;
    hash = "sha256-s7r6wS7H19+is3CFr+dLaTiq0N/gaO/8IFknmr+OAJk=";
    # Most patches are in submodules
    fetchSubmodules = true;
  };

  postPatch = ''
    substituteInPlace \
      skytemple_files/patch/arm_patcher.py \
      skytemple_files/data/data_cd/armips_importer.py \
      --replace-fail \
        "exec_name = os.getenv(\"SKYTEMPLE_ARMIPS_EXEC\", f\"{prefix}armips\")" \
        "exec_name = \"${armips}/bin/armips\""
  '';

  buildInputs = [ armips ];

  nativeCheckInputs = [
    parameterized
    pytestCheckHook
    xmldiff
  ]
  ++ finalAttrs.passthru.optional-dependencies.spritecollab;

  preCheck = "pushd test";
  postCheck = "popd";
  build-system = [ setuptools ];

  dependencies = [
    appdirs
    dungeon-eos
    explorerscript
    ndspy
    pillow
    pmdsky-debug-py
    pyyaml
    range-typed-integers
    skytemple-rust
  ];

  disabledTestPaths = [
    "skytemple_files_test/common/spritecollab/sc_online_test.py"
    "skytemple_files_test/compression_container/atupx/atupx_test.py" # Particularly long test
  ];

  optional-dependencies = {
    spritecollab = [
      aiohttp
      gql
      graphql-core
      lru-dict
    ]
    ++ gql.optional-dependencies.aiohttp;
  };

  pyproject = true;
  pythonImportsCheck = [ "skytemple_files" ];

  pythonRelaxDeps = [
    "pmdsky-debug-py"
  ];

  meta = {
    description = "Python library to edit the ROM of Pokémon Mystery Dungeon Explorers of Sky";
    homepage = "https://github.com/SkyTemple/skytemple-files";
    license = lib.licenses.gpl3Plus;
    maintainers = with lib.maintainers; [ marius851000 ];

    badPlatforms = [
      # pyobjc is missing
      lib.systems.inspect.patterns.isDarwin
    ];

    mainProgram = "skytemple_export_maps";
  };
})
