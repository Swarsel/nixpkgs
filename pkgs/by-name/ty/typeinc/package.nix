{
  lib,
  fetchFromGitHub,
  installShellFiles,
  nix-update-script,
  python3Packages,
  versionCheckHook,
}:
python3Packages.buildPythonApplication (finalAttrs: {
  pname = "typeinc";
  version = "1.0.3";

  src = fetchFromGitHub {
    owner = "AnirudhG07";
    repo = "Typeinc";
    tag = "v${finalAttrs.version}";
    hash = "sha256-/R3mNxZE4Pt4UlCljsQphHBCoA2JIZrTorqU4Adcdp0=";
  };

  nativeBuildInputs = [ installShellFiles ];
  nativeCheckInputs = [ versionCheckHook ];

  postInstall = ''
    installManPage docs/man/typeinc.1
  '';

  build-system = [ python3Packages.hatchling ];
  pyproject = true;
  passthru.updateScript = nix-update-script { };

  meta = {
    description = "Terminal tool to test your typing speed with various difficulty levels";
    homepage = "https://github.com/AnirudhG07/Typeinc";
    license = lib.licenses.asl20;
    maintainers = with lib.maintainers; [ lonerOrz ];
    platforms = lib.platforms.unix;
    mainProgram = "typeinc";
  };
})
