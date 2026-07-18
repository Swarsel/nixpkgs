{
  lib,
  stdenv,
  buildFHSEnv,
  fetchzip,
}:

let
  version = "23.1.14";
  pname = "cockroachdb";

  # For several reasons building cockroach from source has become
  # nearly impossible. See https://github.com/NixOS/nixpkgs/pull/152626
  # Therefore we use the pre-build release binary and wrap it with buildFHSUserEnv to
  # work on nix.
  # You can generate the hashes with
  # nix flake prefetch <url>
  srcs = {
    aarch64-linux = fetchzip {
      hash = "sha256-cwczzmSKKQs/DN6WZ/FF6nJC82Pu47akeDqWdBMgdz0=";
      url = "https://binaries.cockroachdb.com/cockroach-v${version}.linux-arm64.tgz";
    };

    x86_64-linux = fetchzip {
      hash = "sha256-goCBE+zv9KArdoMsI48rlISurUM0bL/l1OEYWQKqzv0=";
      url = "https://binaries.cockroachdb.com/cockroach-v${version}.linux-amd64.tgz";
    };
  };
  src =
    srcs.${stdenv.hostPlatform.system} or (throw "Unsupported system: ${stdenv.hostPlatform.system}");

in
buildFHSEnv {
  inherit pname version;

  extraInstallCommands = ''
    cp -P $out/bin/cockroachdb $out/bin/cockroach
  '';

  runScript = "${src}/cockroach";

  meta = {
    description = "Scalable, survivable, strongly-consistent SQL database";
    homepage = "https://www.cockroachlabs.com";

    license = with lib.licenses; [
      bsl11
      mit
      cockroachdb-community-license
    ];

    sourceProvenance = with lib.sourceTypes; [ binaryNativeCode ];

    maintainers = with lib.maintainers; [
      rushmorem
      thoughtpolice
    ];

    platforms = [
      "aarch64-linux"
      "x86_64-linux"
    ];
  };
}
