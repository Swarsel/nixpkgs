{
  lib,
  derivationWithMeta,
  hostPlatform,
  platforms,
  src,
  stage0Arch,
  version,
}:

let
  hash =
    {
      "AArch64" = "sha256-XTPsoKeI6wTZAF0UwEJPzuHelWOJe//wXg4HYO0dEJo=";
      "AMD64" = "sha256-DCzZduYrix9yOeJoem/Jhz/WDzAss7UWwjZbkXJq6Ms=";
      "x86" = "sha256-DFmSpy4EYoKBSuPQRqtTsUfIUjlg794PnMrEg5stOFY=";
    }
    .${stage0Arch} or (throw "Unsupported system: ${hostPlatform.system}");

  # Pinned from https://github.com/oriansj/stage0-posix/commit/45d90f5955b6907dc6cdea9ebafce558359edcd3
  # This 181 byte seed is the only pre-compiled binary in the bootstrap chain.
  hex0-seed = import <nix/fetchurl.nix> {
    inherit hash;
    executable = true;
    name = "hex0-seed";
    url = "https://github.com/oriansj/bootstrap-seeds/raw/cedec6b8066d1db229b6c77d42d120a23c6980ed/POSIX/${stage0Arch}/hex0-seed";
  };
in
derivationWithMeta {
  inherit version;
  pname = "hex0";

  args = [
    "${src}/${stage0Arch}/hex0_${stage0Arch}.hex0"
    (placeholder "out")
  ];

  builder = hex0-seed;
  outputHash = hash;
  outputHashAlgo = "sha256";
  # Ensure the untrusted hex0-seed binary produces a known-good hex0
  outputHashMode = "recursive";
  passthru = { inherit hex0-seed; };

  meta = {
    inherit platforms;
    description = "Minimal assembler for bootstrapping";
    homepage = "https://github.com/oriansj/stage0-posix";
    license = lib.licenses.gpl3Plus;
    teams = [ lib.teams.minimal-bootstrap ];
  };
}
