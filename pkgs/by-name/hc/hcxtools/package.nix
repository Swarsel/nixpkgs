{
  lib,
  stdenv,
  fetchFromGitHub,
  curl,
  openssl,
  pkg-config,
  zlib,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "hcxtools";
  version = "7.1.2";

  src = fetchFromGitHub {
    owner = "ZerBea";
    repo = "hcxtools";
    tag = finalAttrs.version;
    hash = "sha256-v33RpDKA4OeUU4YXXWhHpdlqQvxk4HIWQKCPskdTSTU=";
  };

  nativeBuildInputs = [ pkg-config ];

  buildInputs = [
    curl
    openssl
    zlib
  ];

  makeFlags = [
    "PREFIX=${placeholder "out"}"
  ];

  meta = {
    description = "Tools for capturing wlan traffic and conversion to hashcat and John the Ripper formats";
    homepage = "https://github.com/ZerBea/hcxtools";
    changelog = "https://github.com/ZerBea/hcxtools/releases/tag/${finalAttrs.src.tag}";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ dywedir ];
    platforms = lib.platforms.linux;
  };
})
