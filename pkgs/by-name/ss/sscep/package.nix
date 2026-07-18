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
  pname = "sscep";
  version = "0.10.0";

  src = fetchFromGitHub {
    owner = "certnanny";
    repo = "sscep";
    rev = "v${finalAttrs.version}";
    hash = "sha256-wlxQONOCLPuNdI6AyMJoLP09cs+ak7Jv9idhXTT5RWA=";
  };

  nativeBuildInputs = [
    autoreconfHook
    pkg-config
  ];

  buildInputs = [ openssl ];
  passthru.updateScript = nix-update-script { };

  meta = {
    description = "Client-only implementation of the SCEP (Cisco System's Simple Certificate Enrollment Protocol)";
    homepage = "https://github.com/certnanny/sscep";

    license = [
      lib.licenses.bsd2
      lib.licenses.openssl
    ];

    maintainers = [ lib.maintainers.stv0g ];
    platforms = lib.platforms.all;
  };
})
