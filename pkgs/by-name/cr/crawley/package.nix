{
  lib,
  fetchFromGitHub,
  buildGoModule,
  installShellFiles,
}:

buildGoModule (finalAttrs: {
  pname = "crawley";
  version = "1.7.20";

  src = fetchFromGitHub {
    owner = "s0rg";
    repo = "crawley";
    rev = "v${finalAttrs.version}";
    hash = "sha256-paKlo/awxxji1TzCC4jEJT2r2svS6AiI6GiwOiBs4Ps=";
  };

  nativeBuildInputs = [ installShellFiles ];
  vendorHash = "sha256-jqJtWLwLO0UsDa6Al2Jb0fc3nwSWMMNc/ikxtMOPpCE=";

  postInstall = ''
    installShellCompletion --cmd crawley \
      --bash <(echo "complete -C $out/bin/crawley crawley") \
      --zsh <(echo "complete -o nospace -C $out/bin/crawley crawley")
  '';

  ldflags = [
    "-w"
    "-s"
  ];

  meta = {
    description = "Unix-way web crawler";
    homepage = "https://github.com/s0rg/crawley";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ ltstf1re ];
    mainProgram = "crawley";
  };
})
