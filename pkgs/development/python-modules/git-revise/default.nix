{
  lib,
  stdenv,
  fetchFromGitHub,
  buildPythonPackage,
  git,
  gnupg,
  hatchling,
  openssh,
  pytestCheckHook,
}:

buildPythonPackage (finalAttrs: {
  pname = "git-revise";
  version = "0.8.0";

  # Missing tests on PyPI
  src = fetchFromGitHub {
    owner = "mystor";
    repo = "git-revise";
    tag = "v${finalAttrs.version}";
    hash = "sha256-OdkhYEq30RtDOeCQWl/L9FMgCttznzihbYgT8B6KYuY=";
  };

  nativeCheckInputs = [
    git
    openssh
    pytestCheckHook
  ]
  ++ lib.optionals (!stdenv.hostPlatform.isDarwin) [
    gnupg
  ];

  build-system = [ hatchling ];

  disabledTests = lib.optionals stdenv.hostPlatform.isDarwin [
    # `gpg: agent_genkey failed: No agent running`
    "test_gpgsign"
  ];

  pyproject = true;

  meta = {
    description = "Efficiently update, split, and rearrange git commits";
    homepage = "https://github.com/mystor/git-revise";
    changelog = "https://github.com/mystor/git-revise/blob/${finalAttrs.src.tag}/CHANGELOG.md";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ _9999years ];
    mainProgram = "git-revise";
  };
})
