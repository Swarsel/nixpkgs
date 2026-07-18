{
  lib,
  fetchFromGitHub,
  buildGo125Module,
  installShellFiles,
  nixosTests,
  scdoc,
}:

buildGo125Module rec {
  pname = "go-camo";
  version = "2.7.5";

  src = fetchFromGitHub {
    owner = "cactus";
    repo = "go-camo";
    tag = "v${version}";
    hash = "sha256-P0n1rnxR9GQQw53MvHII7EXc4gWRThL4k1kulHTz9FU=";
  };

  nativeBuildInputs = [
    installShellFiles
    scdoc
  ];

  vendorHash = "sha256-Fl+amgzolwcuz+eVQzD6mfBdMNzUm6UCwf9BbAt+85U=";

  postBuild = ''
    make man
  '';

  preCheck = ''
    # requires network access
    rm pkg/camo/proxy_{,filter_}test.go
  '';

  postInstall = ''
    installManPage build/man/*
  '';

  ldflags = [
    "-s"
    "-w"
    "-X=main.ServerVersion=${version}"
  ];

  passthru.tests = {
    inherit (nixosTests) go-camo;
  };

  meta = {
    description = "Camo server is a special type of image proxy that proxies non-secure images over SSL/TLS";
    homepage = "https://github.com/cactus/go-camo";
    changelog = "https://github.com/cactus/go-camo/releases/tag/v${version}";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ viraptor ];
    mainProgram = "go-camo";
  };
}
