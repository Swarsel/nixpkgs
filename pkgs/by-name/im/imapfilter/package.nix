{
  lib,
  stdenv,
  fetchFromGitHub,
  lua,
  openssl,
  pcre2,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "imapfilter";
  version = "2.8.5";

  src = fetchFromGitHub {
    owner = "lefcha";
    repo = "imapfilter";
    rev = "v${finalAttrs.version}";
    sha256 = "sha256-EiYVkEyOrgX2WwWzFyQcuVheYZs1s3CGl01fMwtXBog=";
  };

  buildInputs = [
    openssl
    pcre2
    lua
  ];

  makeFlags = [
    "SSLCAFILE=/etc/ssl/certs/ca-bundle.crt"
    "PREFIX=$(out)"
  ];

  meta = {
    description = "Mail filtering utility";
    homepage = "https://github.com/lefcha/imapfilter";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ doronbehar ];
    platforms = lib.platforms.unix;
    mainProgram = "imapfilter";
  };
})
