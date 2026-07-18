{
  lib,
  fetchFromGitHub,
  buildGoModule,
  fetchpatch,
}:

buildGoModule {
  pname = "gotags";
  version = "1.4.1";

  src = fetchFromGitHub {
    owner = "jstemmer";
    repo = "gotags";
    rev = "4c0c4330071a994fbdfdff68f412d768fbcca313";
    hash = "sha256-cHTgt+zW6S6NDWBE6NxSXNPdn84CLD8WmqBe+uXN8sA=";
  };

  patches = [
    # Add Go Modules support
    (fetchpatch {
      hash = "sha256-6v/Ws15y50S6iCI1c0kEw5WHSg+1WqVT4mwdQKoi5G8=";
      url = "https://github.com/jstemmer/gotags/commit/9146999bce9a88e15b5f123d1aa1613926dd9a9c.patch";
    })
  ];

  vendorHash = null;

  ldflags = [
    "-s"
    "-w"
  ];

  meta = {
    description = "ctags-compatible tag generator for Go";
    homepage = "https://github.com/jstemmer/gotags";
    license = lib.licenses.mit;
    maintainers = [ ];
    mainProgram = "gotags";
  };
}
