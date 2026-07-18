{
  lib,
  fetchFromGitHub,
  buildPythonPackage,
  setuptools,
}:

buildPythonPackage (finalAttrs: {
  pname = "hetzner";
  version = "0.8.3";

  src = fetchFromGitHub {
    owner = "aszlig";
    repo = "hetzner";
    tag = "v${finalAttrs.version}";
    hash = "sha256-6si0bdPrM9I4hqyR4ac7l1IsUHp05sAAzfVl4oU8FVo=";
  };

  build-system = [ setuptools ];
  pyproject = true;

  meta = {
    description = "High-level Python API for accessing the Hetzner robot";
    homepage = "https://github.com/RedMoonStudios/hetzner";
    license = lib.licenses.bsd3;
    maintainers = with lib.maintainers; [ aszlig ];
    mainProgram = "hetznerctl";
  };
})
