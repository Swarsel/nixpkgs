{
  lib,
  stdenv,
  fetchFromGitHub,
  buildGoModule,
  nixosTests,
  olm,
}:

buildGoModule {
  pname = "go-neb";
  version = "unstable-2021-07-21";

  src = fetchFromGitHub {
    owner = "matrix-org";
    repo = "go-neb";
    rev = "8916c80f8ce1732f64b50f9251242ca189082e76";
    sha256 = "sha256-kuH4vbvS4G1bczxUdY4bd4oL4pIZzuueUxdEp4xuzJM=";
  };

  buildInputs = [ olm ];
  vendorHash = "sha256-5Vg7aUkqiFIQuxmsDOJjvXoeA5NjMoBoD0XBhC+o4GA=";
  doCheck = false;
  subPackages = [ "." ];
  passthru.tests.go-neb = nixosTests.go-neb;

  meta = {
    description = "Extensible matrix bot written in Go";
    homepage = "https://github.com/matrix-org/go-neb";
    license = lib.licenses.asl20;

    maintainers = with lib.maintainers; [
      hexa
      maralorn
    ];

    mainProgram = "go-neb";
    broken = stdenv.hostPlatform.isDarwin;
  };
}
