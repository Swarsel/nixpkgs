{
  lib,
  fetchFromGitHub,
  buildPythonPackage,
  langcodes,
  nix-update-script,
  pytestCheckHook,
  uv-build,
}:

buildPythonPackage (finalAttrs: {
  pname = "unidata-blocks";
  version = "0.0.25";

  src = fetchFromGitHub {
    owner = "TakWolf";
    repo = "unidata-blocks";
    tag = finalAttrs.version;
    hash = "sha256-BWcKqTMYdJ59XncPL29wCms2kCVTrcrV1zSY8mkbErs=";
  };

  nativeCheckInputs = [ pytestCheckHook ];
  build-system = [ uv-build ];
  dependencies = [ langcodes ];
  pyproject = true;
  pythonImportsCheck = [ "unidata_blocks" ];
  passthru.updateScript = nix-update-script { };

  meta = {
    description = "Library that helps query unicode blocks by Blocks.txt";
    homepage = "https://github.com/TakWolf/unidata-blocks";
    license = lib.licenses.mit;

    maintainers = with lib.maintainers; [
      TakWolf
      h7x4
    ];
  };
})
