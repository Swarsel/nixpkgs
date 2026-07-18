{
  lib,
  fetchFromGitHub,
  python3,
}:

python3.pkgs.buildPythonApplication (finalAttrs: {
  pname = "certsync";
  version = "0.1.6";

  src = fetchFromGitHub {
    owner = "zblurx";
    repo = "certsync";
    tag = finalAttrs.version;
    hash = "sha256-UNeO9Ldf6h6ykziKVCdAoBIzL5QedbRLFEwyeWDCtUU=";
  };

  build-system = with python3.pkgs; [ poetry-core ];

  dependencies = with python3.pkgs; [
    certipy-ad
    tqdm
  ];

  pyproject = true;
  pythonImportsCheck = [ "certsync" ];
  pythonRelaxDeps = [ "certipy-ad" ];

  meta = {
    description = "Dump NTDS with golden certificates and UnPAC the hash";
    homepage = "https://github.com/zblurx/certsync";
    changelog = "https://github.com/zblurx/certsync/releases/tag/${finalAttrs.src.tag}";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ fab ];
    mainProgram = "certsync";
  };
})
