{
  lib,
  stdenv,
  fetchFromGitHub,
  buildGoModule,
  lazysql,
  libx11,
  testers,
  darwin ? null,
}:

buildGoModule rec {
  pname = "lazysql";
  version = "0.5.5";

  src = fetchFromGitHub {
    owner = "jorgerojas26";
    repo = "lazysql";
    rev = "v${version}";
    hash = "sha256-Grr1R88XguW/jT5Vj/m11Cr+Im2+mnVZw23QrO1ZzMk=";
  };

  buildInputs = lib.optionals stdenv.hostPlatform.isLinux [ libx11 ];
  vendorHash = "sha256-FbAt/HsjoxqAKWQqqWN2xuyyTG2Ic4DcyEU4O0rjpQE=";

  ldflags = [
    "-X main.version=${version}"
  ];

  passthru.tests.version = testers.testVersion {
    command = "lazysql --version";
    package = lazysql;
  };

  meta = {
    description = "Cross-platform TUI database management tool written in Go";
    homepage = "https://github.com/jorgerojas26/lazysql";
    license = lib.licenses.mit;
    maintainers = [ ];
    mainProgram = "lazysql";
  };
}
