{
  lib,
  buildGoModule,
  fetchgit,
  gnumake,
}:
let
  version = "1.2.3";
  src = fetchgit {
    url = "https://git.jakstys.lt/motiejus/undocker.git";
    rev = "v${version}";
    hash = "sha256-hyP85pYtXxucAliilUt9Y2qnrfPeSjeGsYEFJndJWyA=";
  };
in
buildGoModule {
  inherit version src;
  pname = "undocker";
  nativeBuildInputs = [ gnumake ];
  vendorHash = null;
  buildPhase = "make VSN=v${version} VSNHASH=${src.rev} undocker";
  installPhase = "install -D undocker $out/bin/undocker";

  meta = {
    description = "CLI tool to convert a Docker image to a flattened rootfs tarball";
    homepage = "https://git.jakstys.lt/motiejus/undocker";
    license = lib.licenses.asl20;

    maintainers = with lib.maintainers; [
      jordanisaacs
      motiejus
    ];

    mainProgram = "undocker";
  };
}
