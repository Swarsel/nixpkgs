{
  lib,
  stdenv,
  fetchFromGitHub,
  libxcb,
  rustPlatform,
}:

rustPlatform.buildRustPackage (finalAttrs: {
  pname = "cotp";
  version = "1.9.10";

  src = fetchFromGitHub {
    owner = "replydev";
    repo = "cotp";
    rev = "v${finalAttrs.version}";
    hash = "sha256-yVzVo4l2bMZXrWlDfJXSgHUmic7Fe0Og+I5ROv3iQCQ=";
  };

  buildInputs = lib.optionals stdenv.hostPlatform.isLinux [ libxcb ];
  cargoHash = "sha256-M0lI/DAMUVRMNbvoLc2w7PtU0rjjXiMYZM6vzfdEi0s=";

  meta = {
    description = "Trustworthy, encrypted, command-line TOTP/HOTP authenticator app with import functionality";
    homepage = "https://github.com/replydev/cotp";
    license = lib.licenses.gpl3Only;
    maintainers = with lib.maintainers; [ davsanchez ];
    mainProgram = "cotp";
  };
})
