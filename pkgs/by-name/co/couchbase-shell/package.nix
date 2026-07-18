{
  lib,
  stdenv,
  fetchFromGitHub,
  couchbase-shell,
  nix-update-script,
  openssl,
  pkg-config,
  rustPlatform,
  testers,
}:

rustPlatform.buildRustPackage rec {
  pname = "couchbase-shell";
  version = "1.3.0";

  src = fetchFromGitHub {
    owner = "couchbaselabs";
    repo = "couchbase-shell";
    rev = "v${version}";
    hash = "sha256-t4y0VxjRaJ5G/vpqq3/oLE/pIXSDAk+l+9fCcr9n6I4=";
  };

  nativeBuildInputs = [
    pkg-config
  ];

  buildInputs = [
    openssl
  ];

  cargoHash = "sha256-f2WYczO2kr5BloXGLjjlnmyaKlr9+IH7i8cqGFUEcVA=";
  # tests need couchbase server
  doCheck = false;

  passthru = {
    tests.version = testers.testVersion {
      package = couchbase-shell;
    };

    updateScript = nix-update-script { };
  };

  meta = {
    description = "Shell for Couchbase Server and Cloud";
    homepage = "https://couchbase.sh/";
    license = lib.licenses.asl20;
    maintainers = with lib.maintainers; [ petrkozorezov ];
    platforms = lib.platforms.linux;
    mainProgram = "cbsh";
  };
}
