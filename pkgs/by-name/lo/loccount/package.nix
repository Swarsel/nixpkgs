{
  lib,
  fetchFromGitLab,
  buildGoModule,
  python3,
}:
buildGoModule (finalAttrs: {
  pname = "loccount";
  version = "2.16";

  src = fetchFromGitLab {
    owner = "esr";
    repo = "loccount";
    rev = finalAttrs.version;
    hash = "sha256-uHX45KZO6R0tgTU10csKLiVYZZ/ea2V6BwhF6vfKKtA=";
  };

  nativeBuildInputs = [ python3 ];
  vendorHash = null;

  preBuild = ''
    patchShebangs --build tablegen.py

    go generate
  '';

  excludedPackages = "tests";

  ldflags = [
    "-s"
    "-w"
  ];

  meta = {
    description = "Re-implementation of sloccount in Go";

    longDescription = ''
      loccount is a re-implementation of David A. Wheeler's sloccount tool
      in Go.  It is faster and handles more different languages. Because
      it's one source file in Go, it is easier to maintain and extend than the
      multi-file, multi-language implementation of the original.

      The algorithms are largely unchanged and can be expected to produce
      identical numbers for languages supported by both tools.  Python is
      an exception; loccount corrects buggy counting of single-quote multiline
      literals in sloccount 2.26.
    '';

    homepage = "https://gitlab.com/esr/loccount";
    license = lib.licenses.bsd2;
    maintainers = with lib.maintainers; [ calvertvl ];
    mainProgram = "loccount";
    downloadPage = "https://gitlab.com/esr/loccount/tree/master";
  };
})
