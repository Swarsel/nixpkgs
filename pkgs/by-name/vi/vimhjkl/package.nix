{
  lib,
  fetchFromGitHub,
  nix-update-script,
  python3Packages,
  testers,
}:

python3Packages.buildPythonApplication (finalAttrs: {
  pname = "vimhjkl";
  version = "0.6.0";

  src = fetchFromGitHub {
    owner = "S-Sigdel";
    repo = "vimhjkl";
    tag = "v${finalAttrs.version}";
    hash = "sha256-uBXz2O2PwtnmibaR4e/l+lKIUh7WN2Hvh6nUfpUuEeA=";
  };

  postPatch = ''
    substituteInPlace pyproject.toml \
      --replace-fail "uv_build>=0.11,<0.12" "uv_build"
  '';

  __structuredAttrs = true;

  build-system = [
    python3Packages.uv-build
  ];

  pyproject = true;

  pythonImportsCheck = [
    "vimhjkl"
  ];

  passthru = {
    tests.version = testers.testVersion {
      package = finalAttrs.finalPackage;
    };

    updateScript = nix-update-script { };
  };

  meta = {
    description = "Learn vim from your terminal with spaced repetition";
    homepage = "https://github.com/S-Sigdel/vimhjkl";
    changelog = "https://github.com/S-Sigdel/vimhjkl/releases/tag/${finalAttrs.src.tag}";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ MoritzBoehme ];
    mainProgram = "vimhjkl";
  };
})
