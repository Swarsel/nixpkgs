{
  lib,
  fetchFromGitLab,
  nix-update-script,
  perl,
  rustPlatform,
}:
rustPlatform.buildRustPackage (finalAttrs: {
  pname = "oniux";
  version = "0.10.0";

  src = fetchFromGitLab {
    owner = "tpo/core";
    repo = "oniux";
    tag = "v${finalAttrs.version}";
    hash = "sha256-ys6RjLyfhoAIiIlf8pv971txPubobY627jhk84HZhsw=";
    domain = "gitlab.torproject.org";
  };

  nativeBuildInputs = [
    perl
  ];

  cargoHash = "sha256-4sXCZ2P4HFsW3g/CSIB2gwBMSddNXzdIav1tSWWOO9A=";
  passthru.updateScript = nix-update-script { };

  meta = {
    description = "Isolate Applications over Tor using Linux Namespaces";
    homepage = "https://gitlab.torproject.org/tpo/core/oniux";

    license =
      with lib.licenses;
      OR [
        asl20
        mit
      ];

    maintainers = with lib.maintainers; [ tnias ];
    platforms = lib.platforms.linux;
    mainProgram = "oniux";
  };
})
