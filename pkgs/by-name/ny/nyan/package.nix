{
  lib,
  stdenv,
  fetchFromGitHub,
  clang,
  cmake,
  flex,
  nix-update-script,
  versionCheckHook,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "nyan";
  version = "0.3.1";

  src = fetchFromGitHub {
    owner = "SFTtech";
    repo = "nyan";
    tag = "v${finalAttrs.version}";
    hash = "sha256-BtvMZaQutcPqTSCN5gxYUU3CQTyCns1ldkcnjwJOFa8=";
  };

  strictDeps = true;

  nativeBuildInputs = [
    clang
    cmake
    flex
  ];

  buildInputs = [
    flex
  ];

  doInstallCheck = true;

  nativeInstallCheckHooks = [
    versionCheckHook
  ];

  versionCheckProgram = "${placeholder "out"}/bin/nyancat";

  passthru = {
    updateScript = nix-update-script { };
  };

  meta = {
    description = "Typesafe hierarchical key-value database";
    homepage = "https://openage.sft.mx";
    changelog = "https://github.com/SFTtech/nyan/releases/tag/v${finalAttrs.version}";
    license = lib.licenses.lgpl3Plus;
    maintainers = with lib.maintainers; [ ethancedwards8 ];
    platforms = lib.platforms.unix;
    mainProgram = "nyancat";
  };
})
