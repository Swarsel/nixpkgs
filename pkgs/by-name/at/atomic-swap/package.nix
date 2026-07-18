{
  lib,
  fetchFromGitHub,
  buildGoModule,
  makeWrapper,
  monero-cli,
  nix-update-script,
}:

buildGoModule (finalAttrs: {
  pname = "atomic-swap";
  version = "0.4.3";

  src = fetchFromGitHub {
    owner = "AthanorLabs";
    repo = "atomic-swap";
    rev = "v${finalAttrs.version}";
    hash = "sha256-MOylUZ6BrvlxUrsZ5gg3JzW9ROG5UXeGhq3YoPZKdHs=";
  };

  nativeBuildInputs = [ makeWrapper ];
  vendorHash = "sha256-fGQ6MI+3z7wRL0y7AUERVtN0V2rcRa+vqeB8+3FMzzc=";
  # integration tests require network access
  doCheck = false;

  postInstall = ''
    wrapProgram $out/bin/swapd --prefix PATH : ${lib.makeBinPath [ monero-cli ]}
  '';

  subPackages = [
    "cmd/swapcli"
    "cmd/swapd"
    "cmd/bootnode"
  ];

  passthru.updateScript = nix-update-script { };

  meta = {
    description = "ETH-XMR atomic swap implementation";
    homepage = "https://github.com/AthanorLabs/atomic-swap";
    changelog = "https://github.com/AthanorLabs/atomic-swap/releases/tag/v${finalAttrs.version}";
    license = with lib.licenses; [ lgpl3Only ];

    maintainers = with lib.maintainers; [
      happysalada
      lord-valen
    ];
  };
})
