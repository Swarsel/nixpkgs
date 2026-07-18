{
  lib,
  fetchFromGitHub,
  bats,
  bc,
  buildPythonApplication,
  callPackage,
  click,
  commentjson,
  fetchpatch,
  kicad,
  markdown2,
  nix-update-script,
  numpy,
  openscad,
  pcbnewtransition,
  pybars3,
  pytestCheckHook,
  python,
  setuptools,
  shapely,
  versionCheckHook,
  versioneer,
  wxpython,
  zip,
}:
let
  solidpython = callPackage ./solidpython { };
in
buildPythonApplication (finalAttrs: {
  pname = "kikit";
  version = "1.8.0";

  src = fetchFromGitHub {
    owner = "yaqwsx";
    repo = "KiKit";
    tag = "v${finalAttrs.version}";
    hash = "sha256-QhtdQgMgHaB0xj2hQ4MCptr5DDgCOfRClUSyYzrFQis=";

    # Upstream uses versioneer, which relies on gitattributes substitution.
    # This leads to non-reproducible archives on GitHub.
    # See
    # https://github.com/NixOS/nixpkgs/issues/84312
    # https://github.com/NixOS/nixpkgs/pull/395213
    # https://github.com/python-versioneer/python-versioneer/issues/217
    postFetch = ''
      rm "$out/kikit/_version.py"
    '';
  };

  patches = [
    (fetchpatch {
      hash = "sha256-AmvH822nAubqVhl1PEKvE0Ij/K0NrBsSvnMUJXgxmfI=";
      name = "fix-stencil-arc-numpy2.patch";
      url = "https://github.com/yaqwsx/KiKit/commit/036ca08fc380dd2c5b8b3ba2adc4215f4114e975.patch?full_index=1";
    })
  ];

  nativeBuildInputs = [
    versioneer
    bc
    zip
  ];

  nativeCheckInputs = [
    pytestCheckHook
    versionCheckHook
    bats
  ];

  preCheck = ''
    export PATH=$PATH:$out/bin

    make test-system

    # pytest needs to run in a subdir. See https://github.com/yaqwsx/KiKit/blob/v1.3.0/Makefile#L43
    cd test/units
  '';

  # Recreate _version.py, deleted at fetch time due to non-reproducibility.
  # should be done in postInstall to overwrite what versioneer generates again during the build phase
  postInstall = ''
    echo 'def get_versions(): return {"version": "${finalAttrs.version}"}' > $out/${python.sitePackages}/kikit/_version.py
  '';

  build-system = [
    setuptools
  ];

  dependencies = [
    kicad
    numpy
    click
    markdown2
    # OpenSCAD is an optional dependency (see
    # https://github.com/yaqwsx/KiKit/blob/v1.5.0/docs/installation/intro.md#optional-dependencies).
    openscad
    commentjson
    # https://github.com/yaqwsx/KiKit/issues/575
    wxpython
    pcbnewtransition
    pybars3
    shapely
    # https://github.com/yaqwsx/KiKit/issues/576
    solidpython
  ];

  pyproject = true;

  pythonImportsCheck = [
    "kikit"
  ];

  passthru.updateScript = nix-update-script { };

  meta = {
    description = "Automation for KiCAD boards";
    homepage = "https://github.com/yaqwsx/KiKit/";
    changelog = "https://github.com/yaqwsx/KiKit/releases/tag/${finalAttrs.src.tag}";
    license = lib.licenses.mit;

    maintainers = with lib.maintainers; [
      jfly
      matusf
    ];

    mainProgram = "kikit";
    teams = with lib.teams; [ ngi ];
  };
})
