{
  lib,
  fetchFromGitHub,
  buildGoModule,
}:

buildGoModule (finalAttrs: {
  pname = "doc2go";
  version = "0.12.1";

  src = fetchFromGitHub {
    owner = "abhinav";
    repo = "doc2go";
    rev = "v${finalAttrs.version}";
    hash = "sha256-q3er94/WLCqXIOQaj7Kdty7yIuaLO7qXt6GiGxIxrPQ=";
  };

  vendorHash = "sha256-4s9gVjx+qiBRmL4abBN3FPuH4iMUapIQr1nwN40VmRQ=";

  checkFlags = [
    # needs to fetch additional go modules
    "-skip=TestFinder_ImportedPackage/Modules"
  ];

  preCheck = ''
    # run all tests
    unset subPackages
  '';

  # integration is it's own module
  excludedPackages = [ "integration" ];

  ldflags = [
    "-s"
    "-w"
    "-X main._version=${finalAttrs.version}"
  ];

  subPackages = [ "." ];

  meta = {
    description = "Your Go project's documentation, to-go";

    longDescription = ''
      doc2go is a command line tool that generates static HTML documentation
      from your Go code. It is a self-hosted static alternative to
      https://pkg.go.dev/ and https://godocs.io/.
    '';

    homepage = "https://github.com/abhinav/doc2go";
    changelog = "https://github.com/abhinav/doc2go/blob/${finalAttrs.src.rev}/CHANGELOG.md";

    license = with lib.licenses; [
      # general project license
      asl20
      # internal/godoc/synopsis*.go adapted from golang source
      bsd3
    ];

    maintainers = with lib.maintainers; [ jk ];
    mainProgram = "doc2go";
  };
})
