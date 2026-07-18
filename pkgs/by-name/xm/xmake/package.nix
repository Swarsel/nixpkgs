{
  lib,
  stdenv,
  fetchFromGitHub,
  nix-update-script,
  versionCheckHook,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "xmake";
  version = "3.0.9";

  src = fetchFromGitHub {
    owner = "xmake-io";
    repo = "xmake";
    tag = "v${finalAttrs.version}";
    hash = "sha256-JoIXsEvcB65NQ7G06HgNIDqMSVzxlX7jOVxe1bWaEAQ=";
    fetchSubmodules = true;
  };

  doInstallCheck = true;
  nativeInstallCheckInputs = [ versionCheckHook ];

  passthru = {
    updateScript = nix-update-script { };
  };

  meta = {
    description = "Cross-platform build utility based on Lua";
    homepage = "https://xmake.io";
    changelog = "https://github.com/xmake-io/xmake/releases/tag/v${finalAttrs.version}";
    license = lib.licenses.asl20;

    maintainers = with lib.maintainers; [
      wineee
      rennsax
    ];

    mainProgram = "xmake";
  };
})
