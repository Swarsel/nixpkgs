{
  lib,
  fetchFromGitHub,
  buildGoModule,
}:

let
  version = "0.11.0";
in

buildGoModule {
  inherit version;
  pname = "agola";

  src = fetchFromGitHub {
    owner = "agola-io";
    repo = "agola";
    tag = "v${version}";
    hash = "sha256-rRx+N1wuc2YztddQiaoijhkdTilt5Nsp1ZoyByg08vE=";
  };

  vendorHash = "sha256-pNrulS7cjeSQyFJODOrxZvOLam56PLZz8jdFzONzbvA=";
  # somehow the tests get stuck
  doCheck = false;

  ldflags = [
    "-s"
    "-w"
    "-X agola.io/agola/cmd.Version=${version}"
  ];

  tags = [
    "sqlite_unlock_notify"
  ];

  meta = {
    description = "CI/CD Redefined";
    homepage = "https://agola.io";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ happysalada ];
  };
}
