{
  lib,
  rustPlatform,
  fetchFromGitHub,
}:
rustPlatform.buildRustPackage (finalAttrs: {
  pname = "firezone-relay";
  version = "0-unstable-2026-10-30";
  src = fetchFromGitHub {
    owner = "firezone";
    repo = "firezone";
    rev = "6cc4aea7123220786c374354cb70fff0e505be4e";
    hash = "sha256-b+TSp//Y7AJOrGW/fIA0vMZLDXP20XW1/xTQkfoWCFM=";
  };

  cargoHash = "sha256-ZMEsa3ZSX92vbivTTZ5UihbXdK/omjlVlEOmjAjN0c0=";
  sourceRoot = "${finalAttrs.src.name}/rust";
  buildAndTestSubdir = "relay/server";
  # Trust the system certificate store instead of the bundled webpki roots
  env.RUSTFLAGS = "--cfg system_certs";

  postPatch = ''
    # Required to remove profiling arguments which conflict with this builder
    rm .cargo/config.toml

    # The relay can offload TURN traffic to an XDP program, which upstream
    # compiles at build time with a pinned nightly toolchain and bpf-linker.
    # We cannot do that here, so we always use the userspace datapath by
    # building the stub that upstream uses on non-Linux platforms.
    echo 'fn main() {}' > relay/server/build.rs
    substituteInPlace relay/server/src/ebpf.rs \
      --replace-fail '#[cfg(target_os = "linux")]' '#[cfg(any())]' \
      --replace-fail '#[cfg(not(target_os = "linux"))]' '#[cfg(all())]'
  '';

  meta = {
    description = "STUN/TURN server for the Firezone zero-trust access platform";
    homepage = "https://github.com/firezone/firezone";
    license = lib.licenses.asl20;
    maintainers = with lib.maintainers; [
      oddlama
      patrickdag
    ];
    mainProgram = "firezone-relay";
    platforms = lib.platforms.linux;
  };
})
