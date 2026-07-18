{
  lib,
  fetchFromGitHub,
  buildGoModule,
  fetchpatch,
}:

buildGoModule (finalAttrs: {
  pname = "compile-daemon";
  version = "1.4.0";

  src = fetchFromGitHub {
    owner = "githubnemo";
    repo = "CompileDaemon";
    rev = "v${finalAttrs.version}";
    sha256 = "sha256-gpyXy7FO7ZVXJrkzcKHFez4S/dGiijXfZ9eSJtNlm58=";
  };

  patches = [
    (fetchpatch {
      hash = "sha256-Zftbw2nu8zzaoj0uwEwdq7xlyycdC0xxBu/qE9VHASI=";
      url = "https://github.com/githubnemo/CompileDaemon/commit/39bc1352dc62fea06dff40c5eaef81ab1bdb1f14.patch";
    })
  ];

  vendorHash = "sha256-UpktrXY6OntOA1sxKq3qI59zrOwwCuM+gfGGxPmUJRo=";

  ldflags = [
    "-s"
    "-w"
  ];

  meta = {
    description = "Very simple compile daemon for Go";
    homepage = "https://github.com/githubnemo/CompileDaemon";
    license = lib.licenses.bsd2;
    maintainers = [ ];
    mainProgram = "CompileDaemon";
  };
})
