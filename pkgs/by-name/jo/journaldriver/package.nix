{
  lib,
  fetchgit,
  openssl,
  pkg-config,
  rustPlatform,
  systemd,
}:

rustPlatform.buildRustPackage {
  pname = "journaldriver";
  version = "5656.0.0";

  src = fetchgit {
    url = "https://code.tvl.fyi/depot.git:/ops/journaldriver.git";
    # TVL revision r/5656; as of 2023-01-13 the revision tag is
    # unavailable through git, hence the pinned hash.
    rev = "4e191353228197ce548d63cb9955e53661244f9c";
    sha256 = "0bnf67k6pkw4rngn58b5zm19danr4sh2g6rfd4k5w2sa1lzqai04";
  };

  nativeBuildInputs = [ pkg-config ];

  buildInputs = [
    openssl
    systemd
  ];

  cargoHash = "sha256-ycnmLHKWRwKbdY1LZJ+BSwGfXfYJCWbbbFcqfBj3y/Y=";

  meta = {
    description = "Log forwarder from journald to Stackdriver Logging";
    homepage = "https://code.tvl.fyi/about/ops/journaldriver";
    license = lib.licenses.gpl3;
    maintainers = [ lib.maintainers.tazjin ];
    platforms = lib.platforms.linux;
    mainProgram = "journaldriver";
  };
}
