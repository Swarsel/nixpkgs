{
  lib,
  stdenv,
  coreutils,
  curl,
  darwin,
  fetchdarcs,
  gawk,
  installShellFiles,
  makeBinaryWrapper,
  nix-prefetch-darcs,
  nix-prefetch-fossil,
  nix-prefetch-git,
  nix-prefetch-pijul,
  nixtamal,
  ocamlPackages,
  python3Packages,
  removeReferencesTo,
  testers,
}:

ocamlPackages.buildDunePackage (finalAttrs: {
  pname = "nixtamal";
  version = "1.9.0";

  src = fetchdarcs {
    url = "https://darcs.toastal.in.th/nixtamal/stable/";
    rev = finalAttrs.version;
    hash = "sha256-Uybm9zTxIMFq82A4eCayeFCia/uW7HjhIquvO9LTfjE=";
    mirrors = [ "https://smeder.ee/~toastal/nixtamal.darcs" ];
  };

  outputs = [
    "bin"
    "data"
    "doc"
    "lib"
    "man"
    "out"
  ];

  postPatch = ''
    substituteInPlace bin/main.ml --subst-var version
    substituteInPlace lib/lock_loader.ml --subst-var release_year
  '';

  nativeBuildInputs = [
    makeBinaryWrapper
    removeReferencesTo
    installShellFiles
    # Compile-time preprocessing
    ocamlPackages.ppx_deriving
    # Completions
    ocamlPackages.cmdliner
    # For manpages
    python3Packages.docutils
    python3Packages.pygments
  ]
  ++ lib.optional stdenv.hostPlatform.isDarwin darwin.sigtool;

  buildInputs = with ocamlPackages; [
    cmdliner
    fmt
  ];

  propagatedBuildInputs = with ocamlPackages; [
    camomile
    eio
    eio_main
    jingoo
    (jsont.override {
      withBrr = false;
      withBytesrw = true;
    })
    kdl
    logs
    saturn
    stdint
    xdg
  ];

  doCheck = true;

  checkInputs = with ocamlPackages; [
    alcotest
    ppx_deriving_qcheck
    qcheck
    qcheck-alcotest
    qcheck-core
  ];

  installPhase = ''
    runHook preInstall

    dune install \
       -j "$NIX_BUILD_CORES" \
       --cache="disabled" \
       --prefix="$out" \
       --bindir="$bin/bin" \
       --datadir="$data/share" \
       --docdir="$doc/share/doc" \
       --mandir="$man/share/man" \
       --libdir="$lib/lib/ocaml/${ocamlPackages.ocaml.version}/site-lib" \
       nixtamal

    cp -r "$src/meta" "$src/ncl" "$data/share"/*/

    for dep in "${ocamlPackages.ocaml}" "${ocamlPackages.camomile}"; do
       remove-references-to -t "$dep" "$bin/bin/nixtamal"
    done

    wrapProgram "$bin/bin/nixtamal" --prefix PATH : ${
      lib.makeBinPath [
        coreutils
        curl
        gawk
        nix-prefetch-darcs
        nix-prefetch-fossil
        nix-prefetch-git
        nix-prefetch-pijul
      ]
    }

    ${lib.optionalString (stdenv.buildPlatform.canExecute stdenv.hostPlatform) /* sh */ ''
      mkdir -p "$TMPDIR"
      cmdliner tool-completion --standalone-completion bash nixtamal >"$TMPDIR/completion.bash"
      cmdliner tool-completion --standalone-completion zsh nixtamal >"$TMPDIR/completion.zsh"
      substituteInPlace "$TMPDIR/completion.zsh" --replace-fail "_nixtamal_cmdliner" "_nixtamal"

      installShellCompletion --bash --cmd nixtamal "$TMPDIR/completion.bash"
      installShellCompletion --fish --cmd nixtamal "script/completion.fish"
      installShellCompletion --zsh --cmd nixtamal "$TMPDIR/completion.zsh"
    ''}

    runHook postInstall
  '';

  minimalOCamlVersion = "5.3";
  release_year = 2026;

  passthru.tests.version = testers.testVersion {
    command = "${nixtamal.meta.mainProgram} --version";
    package = nixtamal.bin;
  };

  meta = {
    description = "Fulfilling input pinning for Nix";

    longDescription = ''
      • Automate the manual work of input pinning for dependency management
      • Allow easy ways to lock & refresh those inputs
      • Declarative manifest file over imperative CLI flags
      • diff/grep-friendly lockfile
      • Declarative patch/diff management for inputs
      • Host-, forge-, VCS-agnostic
      • Choose eval time fetchers (builtins) or build time fetchers (Nixpkgs, default) — which opens up fetching now-supported Darcs, Pijul, & Fossil
      • Supports mirrors, failing over when a server is down
      • Override hash algorithm on a per-project & per-input basis — including BLAKE3 support
      • Custom freshness commands
      • No experimental Nix features required
    '';

    homepage = "https://nixtamal.toast.al";
    changelog = "https://nixtamal.toast.al/changelog/";
    license = with lib.licenses; [ gpl3Plus ];
    maintainers = with lib.maintainers; [ toastal ];
    platforms = lib.platforms.unix;
    mainProgram = "nixtamal";

    outputsToInstall = [
      "bin"
      "data"
      "doc"
      "man"
    ];
  };
})
