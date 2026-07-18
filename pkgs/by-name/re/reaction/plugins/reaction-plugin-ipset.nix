{
  ipset,
  pkg-config,
  reaction,
  rustPlatform,
  ...
}:
reaction.mkReactionPlugin "reaction-plugin-ipset" {
  nativeBuildInputs = [
    rustPlatform.bindgenHook
    pkg-config
  ];

  buildInputs = [ ipset ];
}
