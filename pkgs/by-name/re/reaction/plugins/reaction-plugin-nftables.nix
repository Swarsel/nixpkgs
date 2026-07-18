{
  nftables,
  pkg-config,
  reaction,
  rustPlatform,
  ...
}:
reaction.mkReactionPlugin "reaction-plugin-nftables" {
  nativeBuildInputs = [
    rustPlatform.bindgenHook
    pkg-config
  ];

  buildInputs = [ nftables ];
}
