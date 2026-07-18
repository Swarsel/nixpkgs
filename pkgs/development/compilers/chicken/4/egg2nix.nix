{
  lib,
  fetchFromGitHub,
  chickenEggs,
  eggDerivation,
  fetchpatch,
}:

# Note: This mostly reimplements the default.nix already contained in
# the tarball. Is there a nicer way than duplicating code?

eggDerivation rec {
  pname = "egg2nix";
  version = "0.5";

  src = fetchFromGitHub {
    owner = "the-kenny";
    repo = "egg2nix";
    rev = version;
    sha256 = "sha256-5ov2SWVyTUQ6NHnZNPRywd9e7oIxHlVWv4uWbsNaj/s=";
  };

  patches = [
    (fetchpatch {
      hash = "sha256-emMnxu6HnpcDWcO7rAe0VOy2ZPfPhqj5bQv9foOkjY0=";
      url = "https://github.com/the-kenny/egg2nix/commit/7d20ed520b8fe4debeefc78271c8c836015f95dc.patch";
    })
  ];

  buildInputs = with chickenEggs; [
    matchable
    http-client
  ];

  meta = {
    description = "Generate nix-expression from CHICKEN scheme eggs";
    homepage = "https://github.com/the-kenny/egg2nix";
    license = lib.licenses.bsd3;
    maintainers = with lib.maintainers; [ corngood ];
    platforms = lib.platforms.unix;
    mainProgram = "egg2nix";
  };
}
