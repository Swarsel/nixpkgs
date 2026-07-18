{
  lib,
  stdenv,
  fetchFromGitHub,
  autoreconfHook,
  nix-update-script,
  openssl,
  pkg-config,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "gensio";
  version = "3.0.2";

  src = fetchFromGitHub {
    owner = "cminyard";
    repo = "gensio";
    rev = "v${finalAttrs.version}";
    sha256 = "sha256-5gxBz6m0tyVESeYe5L6z6PZFhrzqVmQuUFYxtd8n9Jc=";
  };

  nativeBuildInputs = [
    autoreconfHook
    pkg-config
  ];

  buildInputs = lib.optionals stdenv.hostPlatform.isDarwin [ openssl ];

  configureFlags = [
    "--with-python=no"
  ];

  passthru = {
    updateScript = nix-update-script { };
  };

  meta = {
    description = "General Stream I/O";
    homepage = "https://sourceforge.net/projects/ser2net/";
    license = lib.licenses.gpl2;

    maintainers = with lib.maintainers; [
      emantor
      sarcasticadmin
    ];

    platforms = lib.platforms.unix;
    mainProgram = "gensiot";
  };
})
