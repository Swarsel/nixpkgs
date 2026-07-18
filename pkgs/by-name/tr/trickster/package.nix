{
  lib,
  fetchFromGitHub,
  buildGoModule,
  go,
  nixosTests,
}:

buildGoModule rec {
  pname = "trickster";
  version = "1.1.5";

  src = fetchFromGitHub {
    owner = "trickstercache";
    repo = "trickster";
    rev = "v${version}";
    sha256 = "sha256-BRD8IF3s9RaDorVtXRvbKLVVVXWiEQTQyKBR9jFo1eM=";
  };

  vendorHash = null;
  # Tests are broken.
  doCheck = false;

  ldflags = [
    "-extldflags '-static'"
    "-s"
    "-w"
  ]
  ++ (lib.mapAttrsToList (n: v: "-X main.application${n}=${v}") {
    BuildTime = "1970-01-01T00:00:00+0000";
    GitCommitID = rev;
    GoArch = "${go.GOARCH}";
    GoVersion = "go${go.version}}";
  });

  rev = "4595bd6a1ae1165ef497251ad85c646dadc8a925";
  subPackages = [ "cmd/trickster" ];
  passthru.tests = { inherit (nixosTests) trickster; };

  meta = {
    description = "Reverse proxy cache and time series dashboard accelerator";

    longDescription = ''
      Trickster is a fully-featured HTTP Reverse Proxy Cache for HTTP
      applications like static file servers and web APIs.
    '';

    homepage = "https://trickstercache.org/";
    license = lib.licenses.asl20;
    maintainers = with lib.maintainers; [ _1000101 ];
    platforms = lib.platforms.linux;
    mainProgram = "trickster";
  };
}
