{
  lib,
  stdenv,
  fetchFromGitHub,
  nix-update-script,
  nixosTests,
  rustPlatform,
}:

let
  version = "1.5.2";
in

rustPlatform.buildRustPackage {
  inherit version;
  pname = "nsncd";

  src = fetchFromGitHub {
    owner = "twosigma";
    repo = "nsncd";
    tag = "v${version}";
    hash = "sha256-HNg2pf6dUQW95B8x/xWa53+GZVWzpTMRVeqWT3dp/M8=";
  };

  cargoHash = "sha256-kjxRhrgKPLCKWc3/gOvdcmQX7IdxFLuwcV7DRZIte78=";

  checkFlags = [
    # Relies on the test environment to be able to resolve "localhost"
    # on IPv4. That's not the case in the Nix sandbox somehow. Works
    # when running cargo test impurely on a (NixOS|Debian) machine.
    "--skip=ffi::test_gethostbyname2_r"

    # Relies on /etc/services to be present?
    "--skip=handlers::test::test_handle_getservbyname_name"
    "--skip=handlers::test::test_handle_getservbyname_name_proto"
    "--skip=handlers::test::test_handle_getservbyport_port"
    "--skip=handlers::test::test_handle_getservbyport_port_proto"
    "--skip=handlers::test::test_handle_getservbyport_port_proto_aliases"
  ];

  passthru = {
    tests.nscd = nixosTests.nscd;
    updateScript = nix-update-script { extraArgs = [ "--version-regex=^v([0-9][0-9.]+)$" ]; };
  };

  meta = {
    description = "Name service non-caching daemon";

    longDescription = ''
      nsncd is a nscd-compatible daemon that proxies lookups, without caching.
    '';

    homepage = "https://github.com/twosigma/nsncd";
    license = lib.licenses.asl20;

    maintainers = with lib.maintainers; [
      flokli
      picnoir
    ];

    mainProgram = "nsncd";
    # never built on aarch64-darwin, x86_64-darwin since first introduction in nixpkgs
    broken = stdenv.hostPlatform.isDarwin;
  };
}
