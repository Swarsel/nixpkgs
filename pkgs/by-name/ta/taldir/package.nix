{
  lib,
  buildGoModule,
  fetchgit,
  recutils,
}:
buildGoModule (finalAttrs: {
  pname = "taldir";
  version = "1.0.5";

  src = fetchgit {
    url = "https://git-www.taler.net/taldir.git";
    tag = "v${finalAttrs.version}";
    hash = "sha256-ZKNkMV0IV6E+yCQeabGXpIQclx1S4YEgFn4whGXTaks=";
  };

  nativeBuildInputs = [
    recutils
  ];

  vendorHash = "sha256-QCwakJTpRP7VT69EzQeInCCGBuNu3WsNCytnQcBdKQw=";

  # From Makefile
  preBuild = ''
    mkdir -p internal/gana

    pushd third_party/gana/gnu-taler-error-codes
    make taler_error_codes.go
    popd

    cp third_party/gana/gnu-taler-error-codes/taler_error_codes.go internal/gana/
  '';

  # dial error (dial tcp [::1]:5432: connect: connection refused)
  doCheck = false;

  subPackages = [
    "cmd/taldir-cli"
    "cmd/taldir-server"
  ];

  meta = {
    description = "Directory service to resolve wallet mailboxes by messenger addresses";
    homepage = "https://git-www.taler.net/taldir.git";
    license = lib.licenses.agpl3Plus;
    # themadbit will maintain after being added to maintainers
    maintainers = [ ];
    teams = with lib.teams; [ ngi ];
  };
})
