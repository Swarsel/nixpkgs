{
  lib,
  fetchFromGitHub,
  buildGoModule,
  libxcrypt,
  makeWrapper,
  nix-update-script,
  openssh,
  shellhub-agent,
  testers,
}:

buildGoModule (finalAttrs: {
  pname = "shellhub-agent";
  version = "0.25.1";

  src = fetchFromGitHub {
    owner = "shellhub-io";
    repo = "shellhub";
    rev = "v${finalAttrs.version}";
    hash = "sha256-JN8taYPj8GOCeDw08c2fLZmQr4IACWum5whfycaG9go=";
  };

  nativeBuildInputs = [ makeWrapper ];
  buildInputs = [ libxcrypt ];
  vendorHash = "sha256-iuXGBYvcNK91RmbfKfMyiMbW4LmBpVI5oE8EEyP7jps=";

  postInstall = ''
    wrapProgram $out/bin/agent --prefix PATH : ${lib.makeBinPath [ openssh ]}
  '';

  ldflags = [
    "-s"
    "-w"
    "-X main.AgentVersion=v${finalAttrs.version}"
  ];

  modRoot = "./agent";

  passthru = {
    tests.version = testers.testVersion {
      version = "v${finalAttrs.version}";
      command = "agent --version";
      package = shellhub-agent;
    };

    updateScript = nix-update-script { };
  };

  meta = {
    description = "Enables easy access any Linux device behind firewall and NAT";

    longDescription = ''
      ShellHub is a modern SSH server for remotely accessing Linux devices via
      command line (using any SSH client) or web-based user interface, designed
      as an alternative to _sshd_. Think ShellHub as centralized SSH for the the
      edge and cloud computing.
    '';

    homepage = "https://shellhub.io/";
    license = lib.licenses.asl20;
    maintainers = with lib.maintainers; [ otavio ];
    platforms = lib.platforms.linux;
    mainProgram = "agent";
  };
})
