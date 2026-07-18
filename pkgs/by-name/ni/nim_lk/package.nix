{
  lib,
  buildNimSbom,
  fetchFromSourcehut,
  makeWrapper,
  nim,
  nix-prefetch,
  nix-prefetch-git,
  openssl,
}:

let
  nimUnwrapped = nim.passthru.nim;
in
buildNimSbom (finalAttrs: {
  src = fetchFromSourcehut {
    owner = "~ehmry";
    repo = "nim_lk";
    rev = finalAttrs.version;
    hash = "sha256-BZNQs8zMtBMcqafvU+WyjtBZQJ8zhQIPSR51j7C9Z6g=";
  };

  patches = [
    ./nil.patch
  ];

  nativeBuildInputs = [ makeWrapper ];
  buildInputs = [ openssl ];

  postFixup = ''
    wrapProgram $out/bin/nim_lk \
      --suffix PATH : ${
        lib.makeBinPath [
          nimUnwrapped
          nix-prefetch
          nix-prefetch-git
        ]
      }
  '';

  meta = finalAttrs.src.meta // {
    description = "Generate Nix specific lock files for Nim packages";
    homepage = "https://git.sr.ht/~ehmry/nim_lk";
    license = lib.licenses.bsd3;
    platforms = lib.platforms.unix;
    mainProgram = "nim_lk";
  };
}) ./sbom.json
