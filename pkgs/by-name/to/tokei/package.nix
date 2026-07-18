{
  lib,
  stdenv,
  fetchFromGitHub,
  fetchpatch2,
  libiconv,
  nix-update-script,
  rustPlatform,
  versionCheckHook,
  zlib,
}:

rustPlatform.buildRustPackage (finalAttrs: {
  pname = "tokei";
  version = "14.0.0";

  src = fetchFromGitHub {
    owner = "XAMPPRocky";
    repo = "tokei";
    tag = "v${finalAttrs.version}";
    hash = "sha256-BpQ+Aurx2CkFRcozUTbmLLAg7v3NkgKXm5y0TiQCfHw=";
  };

  patches = [
    (fetchpatch2 {
      hash = "sha256-1tb+WmjVsTxs8Awf1mbKOBIhJ3ddoOT8ZjBKA2BMocg=";
      # https://github.com/XAMPPRocky/tokei/pull/1209
      url = "https://github.com/XAMPPRocky/tokei/commit/ce8d8535276a2e41878981a8199232986ab96c6b.patch";
    })
  ];

  buildInputs = lib.optionals stdenv.hostPlatform.isDarwin [ libiconv ];
  cargoHash = "sha256-x1Oi+B6DpbsCqnX0Lp5LsmoVHNvdibwj/IEgFvhepqY=";
  checkInputs = lib.optionals stdenv.hostPlatform.isDarwin [ zlib ];
  doInstallCheck = true;
  nativeInstallCheckInputs = [ versionCheckHook ];
  # enable all output formats
  buildFeatures = [ "all" ];
  passthru.updateScript = nix-update-script { };

  meta = {
    description = "Count your code, quickly";

    longDescription = ''
      Tokei is a program that displays statistics about your code. Tokei will show the number of files, total lines within those files and code, comments, and blanks grouped by language.
    '';

    homepage = "https://github.com/XAMPPRocky/tokei";
    changelog = "https://github.com/XAMPPRocky/tokei/blob/v${finalAttrs.version}/CHANGELOG.md";

    license = with lib.licenses; [
      asl20 # or
      mit
    ];

    maintainers = with lib.maintainers; [ defelo ];
    mainProgram = "tokei";
  };
})
