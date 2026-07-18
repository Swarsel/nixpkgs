{
  lib,
  stdenv,
  fetchFromGitHub,
  fetchpatch,
  openssl,
  versionCheckHook,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "mailsend";
  version = "1.19";

  src = fetchFromGitHub {
    owner = "muquit";
    repo = "mailsend";
    tag = finalAttrs.version;
    hash = "sha256-g1V4NrFlIz8oh7IS+cGWG6eje6kBGvPZS7Q131ESrXI=";
  };

  patches = [
    # OpenSSL 1.1 support for HMAC api
    (fetchpatch {
      hash = "sha256-Gy4pZMYoUXcjMatw5BSk+IUKXjgpLCwPXtfC++WPKAM=";
      name = "openssl-1-1-hmac.patch";
      url = "https://github.com/muquit/mailsend/commit/960df6d7a11eef90128dc2ae660866b27f0e4336.patch";
    })
    # Pull fix pending upstream inclusion for parallel build failures:
    #   https://github.com/muquit/mailsend/pull/165
    (fetchpatch {
      hash = "sha256-p8tNnkU6cMopuP63kVtRbD9aenhzL1EAXlvvFh4fucE=";
      name = "parallel-install.patch";
      url = "https://github.com/muquit/mailsend/commit/acd4ebedbce0e4af3c7b6632f905f73e642ca38c.patch";
    })
  ];

  buildInputs = [
    openssl
  ];

  configureFlags = [
    "--with-openssl=${openssl.dev}"
  ];

  env.NIX_CFLAGS_COMPILE = "-Wno-error=implicit-function-declaration";
  doInstallCheck = true;

  nativeInstallCheckInputs = [
    versionCheckHook
  ];

  enableParallelBuilding = true;
  versionCheckProgramArg = "-V";

  meta = {
    description = "CLI email sending tool";
    homepage = "https://github.com/muquit/mailsend";
    license = lib.licenses.bsd3;
    maintainers = with lib.maintainers; [ raskin ];
    platforms = lib.platforms.linux;
    mainProgram = "mailsend";
    downloadPage = "https://github.com/muquit/mailsend/releases";
  };
})
