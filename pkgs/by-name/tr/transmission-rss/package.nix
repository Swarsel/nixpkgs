{
  lib,
  fetchFromGitHub,
  openssl,
  pkg-config,
  rustPlatform,
}:

rustPlatform.buildRustPackage {
  pname = "transmission-rss";
  version = "0.3.1";

  src = fetchFromGitHub {
    owner = "herlon214";
    repo = "transmission-rss";
    rev = "5bbad7a81621a194b7a8b11a56051308a7ccbf06";
    sha256 = "sha256-SkEgxinqPA9feOIF68oewVyRKv3SY6fWWZLGJeH+r4M=";
  };

  nativeBuildInputs = [ pkg-config ];
  buildInputs = [ openssl ];
  cargoHash = "sha256-ETbWV5OjRzQuq/rVyu22YRFjeQcuNA1REyzg46s3q5A=";
  env.OPENSSL_NO_VENDOR = 1;
  cargoPatches = [ ./update-cargo-lock-version.patch ];

  meta = {
    description = "Add torrents to transmission based on RSS list";
    homepage = "https://github.com/herlon214/transmission-rss";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ icewind1991 ];
    mainProgram = "transmission-rss";
  };
}
