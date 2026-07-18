{
  lib,
  fetchFromGitHub,
  buildGoModule,
}:

buildGoModule (finalAttrs: {
  pname = "go-md2man";
  version = "2.0.7";

  src = fetchFromGitHub {
    owner = "cpuguy83";
    repo = "go-md2man";
    rev = "v${finalAttrs.version}";
    sha256 = "sha256-DKqGvdidl6J4lPhIk3okhU4k6MvtSr+hJ9huU/JTai0=";
  };

  vendorHash = "sha256-aMLL/tmRLyGze3RSB9dKnoTv5ZK1eRtgV8fkajWEbU0=";

  meta = {
    description = "Go tool to convert markdown to man pages";
    homepage = "https://github.com/cpuguy83/go-md2man";
    license = lib.licenses.mit;
    maintainers = [ ];
    mainProgram = "go-md2man";
  };
})
