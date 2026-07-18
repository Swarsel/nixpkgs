{
  lib,
  fetchFromGitHub,
  anywidget,
  buildPythonPackage,
  fetchNpmDeps,
  hatch-jupyter-builder,
  hatch-vcs,
  hatchling,
  nix-update-script,
  nodejs,
  npmHooks,
  numpy,
  pytestCheckHook,
  requests,
}:

buildPythonPackage rec {
  pname = "ipyniivue";
  version = "2.4.4";

  src = fetchFromGitHub {
    owner = "niivue";
    repo = "ipyniivue";
    tag = "v${version}";
    hash = "sha256-Jk8Os8g2W5IRqLQSLQeH59ffGgWK/gjuUZgUl+HflVA=";
  };

  postPatch = ''
    cp ${./package-lock.json} ./package-lock.json
  '';

  nativeBuildInputs = [
    nodejs
    npmHooks.npmConfigHook
  ];

  # We do not need the build hooks, because we do not need to
  # build any JS components; these are present already in the PyPI artifact.
  env.HATCH_BUILD_NO_HOOKS = true;

  preBuild = ''
    npm run build
  '';

  nativeCheckInputs = [ pytestCheckHook ];

  build-system = [
    hatchling
    hatch-vcs
    hatch-jupyter-builder
  ];

  dependencies = [
    anywidget
    numpy
    requests
  ];

  npmDeps = fetchNpmDeps {
    inherit src;

    postPatch = ''
      cp ${./package-lock.json} ./package-lock.json
    '';

    hash = "sha256-6TbwAC175mkyR8EThMalWn7qEyaIFDxtKmC/RIuy1dk=";
    name = "${pname}-${version}-npm-deps";
  };

  pyproject = true;
  pythonImportsCheck = [ "ipyniivue" ];

  passthru = {
    # https://github.com/niivue/ipyniivue/pull/139
    updateScript = nix-update-script { extraArgs = [ "--generate-lockfile" ]; };
  };

  meta = {
    description = "Show a nifti image in a webgl 2.0 canvas within a jupyter notebook cell";
    homepage = "https://github.com/niivue/ipyniivue";
    changelog = "https://github.com/niivue/ipyniivue/releases/tag/${src.tag}";
    license = lib.licenses.bsd3;
    maintainers = with lib.maintainers; [ bcdarwin ];
  };
}
