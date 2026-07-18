{
  lib,
  stdenv,
  fetchFromGitHub,
  fetchpatch2,
  nix-update-script,
  protobuf,
  rustPlatform,
  sozu,
  testers,
}:

rustPlatform.buildRustPackage (finalAttrs: {
  pname = "sozu";
  version = "1.1.1";

  src = fetchFromGitHub {
    owner = "sozu-proxy";
    repo = "sozu";
    tag = finalAttrs.version;
    hash = "sha256-a/Pna2l1gRv4kxIyGUuUHlN+lIQemGjZXwM65Ccc24Y=";
  };

  patches = [
    # Fix build with Rust 1.82+ on Darwin: extern blocks must be unsafe.
    (fetchpatch2 {
      hash = "sha256-chXehutcI4+gDwY1uUPgE4t0fgGOsEHPP8gMsnXNB10=";
      url = "https://github.com/sozu-proxy/sozu/commit/ec83fad967f2606d5d668679e138631a70ec7de5.patch?full_index=1";
    })
  ];

  nativeBuildInputs = [ protobuf ];
  cargoHash = "sha256-9ZmlUUdtVAvri9v+EJb6vRQ7Yc3FjRwU5I5Xe8je9/c=";
  doCheck = false;

  passthru = {
    tests.version = testers.testVersion {
      version = "${finalAttrs.version}";
      command = "sozu --version";
      package = sozu;
    };

    updateScript = nix-update-script { };
  };

  meta = {
    description = "Open Source HTTP Reverse Proxy built in Rust for Immutable Infrastructures";
    homepage = "https://www.sozu.io";
    changelog = "https://github.com/sozu-proxy/sozu/releases/tag/${finalAttrs.src.tag}";
    license = lib.licenses.agpl3Only;
    maintainers = [ ];
    mainProgram = "sozu";
    # error[E0432]: unresolved import `std::arch::x86_64`
    broken = !stdenv.hostPlatform.isx86_64;
  };
})
