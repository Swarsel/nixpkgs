{
  lib,
  fetchFromGitHub,
  fetchpatch,
  python3Packages,
}:

python3Packages.buildPythonApplication (finalAttrs: {
  pname = "pre-commit-hook-ensure-sops";
  version = "1.1";

  src = fetchFromGitHub {
    owner = "yuvipanda";
    repo = "pre-commit-hook-ensure-sops";
    tag = "v${finalAttrs.version}";
    hash = "sha256-8sMmHNzmYwOmHYSWoZ4rKb/2lKziFmT6ux+s+chd/Do=";
  };

  patches = [
    # Add the command-line entrypoint to pyproject.toml
    # Can be removed after v1.2 release that includes changes
    (fetchpatch {
      hash = "sha256-mMxAoC3WEciO799Rq8gZ2PJ6FT/GbeSpxlr1EPj7r4s=";
      url = "https://github.com/yuvipanda/pre-commit-hook-ensure-sops/commit/ed88126afa253df6009af7cbe5aa2369f963be1c.patch";
    })
  ];

  # Test entrypoint
  checkPhase = ''
    runHook preCheck
    $out/bin/pre-commit-hook-ensure-sops --help
    runHook postCheck
  '';

  build-system = with python3Packages; [
    setuptools
  ];

  dependencies = with python3Packages; [
    ruamel-yaml
  ];

  pyproject = true;

  pythonImportsCheck = [
    "pre_commit_hook_ensure_sops"
  ];

  meta = {
    description = "Pre-commit hook to ensure that files that should be encrypted with sops are";
    homepage = "https://github.com/yuvipanda/pre-commit-hook-ensure-sops";
    license = lib.licenses.bsd3;
    maintainers = with lib.maintainers; [ nialov ];
    mainProgram = "pre-commit-hook-ensure-sops";
  };
})
