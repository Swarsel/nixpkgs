{
  lib,
  fetchFromGitHub,
  python3,
}:

python3.pkgs.buildPythonApplication (finalAttrs: {
  pname = "penelope";
  version = "0.21.0";

  src = fetchFromGitHub {
    owner = "brightio";
    repo = "penelope";
    tag = "v${finalAttrs.version}";
    hash = "sha256-pBC8qiZBPTwe7BLBLcAFPCb7Lu+7TzZoAzri160/un0=";
  };

  # Project has no tests
  doCheck = false;
  build-system = with python3.pkgs; [ setuptools ];
  pyproject = true;

  meta = {
    description = "Penelope Shell Handler";
    homepage = "https://github.com/brightio/penelope";
    changelog = "https://github.com/brightio/penelope/releases/tag/${finalAttrs.src.tag}";
    license = lib.licenses.gpl3Plus;
    maintainers = with lib.maintainers; [ fab ];
    platforms = lib.platforms.all;
    mainProgram = "penelope";
  };
})
