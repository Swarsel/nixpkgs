{
  lib,
  fetchFromGitHub,
  buildGoModule,
  testers,
}:

buildGoModule rec {
  pname = "goodhosts";
  version = "1.1.3";

  src = fetchFromGitHub {
    owner = "goodhosts";
    repo = "cli";
    rev = "v${version}";
    hash = "sha256-+KlAJV+CeycQHwxrRI9kMkKlDLs8bS+/QwaYv70LEfU=";
  };

  vendorHash = "sha256-FsjCpwvehmRm67Tqwld+0vn4IFO6E46SJnLwRjKVAiw=";

  postInstall = ''
    mv $out/bin/cli $out/bin/goodhosts
  '';

  ldflags = [
    "-s -w -X main.version=${version}"
  ];

  meta = {
    description = "CLI tool for managing hostfiles";
    homepage = "https://github.com/goodhosts/cli/tree/main";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ schinmai-akamai ];
    mainProgram = "goodhosts";
  };
}
