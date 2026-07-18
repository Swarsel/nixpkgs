{
  lib,
  fetchFromGitHub,
  jujutsu,
  makeWrapper,
  rustPlatform,
  versionCheckHook,
}:
rustPlatform.buildRustPackage (finalAttrs: {
  pname = "lazyjj";
  version = "0.6.1";

  src = fetchFromGitHub {
    owner = "Cretezy";
    repo = "lazyjj";
    tag = "v${finalAttrs.version}";
    hash = "sha256-xpRuXefP2agcZojvAUvODDOFJoEyTiMztJM3VNCeryA=";
  };

  nativeBuildInputs = [ makeWrapper ];
  cargoHash = "sha256-LLbMR3FT5Ci7A9TlhRtU0rpMilXZXb4DH85/R776OQY=";

  nativeCheckInputs = [
    jujutsu
  ];

  checkFlags = [
    # This tests checks the output of `jj diff`. However, `jj diff` had a change upstream making the test fail. Skip for now, until the test is updated.
    "--skip=commander::files::tests::get_file_diff"
  ];

  postInstall = ''
    wrapProgram $out/bin/lazyjj \
      --prefix PATH : ${lib.makeBinPath [ jujutsu ]}
  '';

  doInstallCheck = true;

  nativeInstallCheckInputs = [
    versionCheckHook
  ];

  meta = {
    description = "TUI for Jujutsu/jj";
    homepage = "https://github.com/Cretezy/lazyjj";
    changelog = "https://github.com/Cretezy/lazyjj/releases/tag/v${finalAttrs.version}";
    license = lib.licenses.asl20;

    maintainers = with lib.maintainers; [
      colemickens
      GaetanLepage
    ];

    mainProgram = "lazyjj";
  };
})
