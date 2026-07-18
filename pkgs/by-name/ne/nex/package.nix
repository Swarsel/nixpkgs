{
  lib,
  fetchFromGitHub,
  buildGoModule,
}:
# upstream is pretty stale, but it still works, so until they merge module
# support we have to use gopath: see blynn/nex#57
buildGoModule {
  pname = "nex";
  version = "0-unstable-2021-03-30";

  src = fetchFromGitHub {
    owner = "blynn";
    repo = "nex";
    rev = "1a3320dab988372f8910ccc838a6a7a45c8980ff";
    hash = "sha256-DtJkV380T2B5j0+u7lYZfbC0ej0udF4GW2lbRmmbjAM=";
  };

  postPatch = ''
    go mod init github.com/blynn/nex
  '';

  vendorHash = null;
  # Fails with 'nex_test.go:23: got: 7a3661f13445ca7b51de2987bea127d9 wanted: 13f760d2f0dc1743dd7165781f2a318d'
  # Checks failed on master before, but buildGoPackage had checks disabled.
  doCheck = false;
  subPackages = [ "." ];

  meta = {
    description = "Lexer for Go";
    homepage = "https://github.com/blynn/nex";
    license = lib.licenses.gpl3Only;
    maintainers = [ ];
    mainProgram = "nex";
  };
}
