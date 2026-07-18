{
  lib,
  stdenv,
  fetchFromGitHub,
  libffi,
  openssl,
  readline,
  testers,
  valgrind,
  xxd,
  # Boolean flags
  checkLeaks ? false,
  enableFFI ? true,
  enableSSL ? true,
  enableThreads ? true,
  # Configurable inputs
  lineEditingLibrary ? "isocline",
}:

assert lib.elem lineEditingLibrary [
  "isocline"
  "readline"
];
stdenv.mkDerivation (finalAttrs: {
  pname = "trealla";
  version = "2.100.9";

  src = fetchFromGitHub {
    owner = "trealla-prolog";
    repo = "trealla";
    rev = "v${finalAttrs.version}";
    hash = "sha256-lBNGZuI8zKpqVeCc1OYyFhIuL3iBXlNL0e2l/Ubkm6M=";
  };

  postPatch = ''
    substituteInPlace Makefile \
      --replace '-I/usr/local/include' "" \
      --replace '-L/usr/local/lib' "" \
      --replace 'GIT_VERSION :=' 'GIT_VERSION ?='
  '';

  strictDeps = true;
  nativeBuildInputs = [ xxd ];

  buildInputs =
    lib.optionals enableFFI [ libffi ]
    ++ lib.optionals enableSSL [ openssl ]
    ++ lib.optionals (lineEditingLibrary == "readline") [ readline ];

  makeFlags = [
    "GIT_VERSION=\"v${finalAttrs.version}\""
  ]
  ++ lib.optionals (lineEditingLibrary == "isocline") [ "ISOCLINE=1" ]
  ++ lib.optionals (!enableFFI) [ "NOFFI=1" ]
  ++ lib.optionals (!enableSSL) [ "NOSSL=1" ]
  ++ lib.optionals enableThreads [ "THREADS=1" ];

  doCheck = !valgrind.meta.broken;
  nativeCheckInputs = lib.optionals finalAttrs.finalPackage.doCheck [ valgrind ];
  checkFlags = [ "test" ] ++ lib.optionals checkLeaks [ "leaks" ];

  installPhase = ''
    runHook preInstall
    install -Dm755 -t $out/bin tpl
    runHook postInstall
  '';

  enableParallelBuilding = true;

  passthru = {
    tests = {
      version = testers.testVersion {
        version = "v${finalAttrs.version}";
        package = finalAttrs.finalPackage;
      };
    };
  };

  meta = {
    description = "Compact, efficient Prolog interpreter written in ANSI C";

    longDescription = ''
      Trealla is a compact, efficient Prolog interpreter with ISO Prolog
      aspirations.
      Trealla is not WAM-based. It uses tree-walking, structure-sharing and
      deep-binding. Source is byte-code compiled to an AST that is interpreted
      at runtime. The intent and continued aim of Trealla is to be a small,
      easily ported, Prolog core.
      The name Trealla comes from the Liaden Universe books by Lee & Miller
      (where it doesn't seem to mean anything) and also a reference to the
      Trealla region of Western Australia.
    '';

    homepage = "https://trealla-prolog.github.io/trealla/";
    changelog = "https://github.com/trealla-prolog/trealla/releases/tag/v${finalAttrs.version}";
    license = lib.licenses.mit;

    maintainers = with lib.maintainers; [
      siraben
    ];

    platforms = lib.platforms.all;
    mainProgram = "tpl";
  };
})
