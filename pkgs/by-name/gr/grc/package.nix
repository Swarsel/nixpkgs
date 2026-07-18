{
  lib,
  fetchFromGitHub,
  installShellFiles,
  python3Packages,
}:

python3Packages.buildPythonApplication (finalAttrs: {
  pname = "grc";
  version = "1.13";

  src = fetchFromGitHub {
    owner = "garabik";
    repo = "grc";
    rev = "v${finalAttrs.version}";
    sha256 = "1h0h88h484a9796hai0wasi1xmjxxhpyxgixn6fgdyc5h69gv8nl";
  };

  outputs = [
    "out"
    "man"
  ];

  postPatch = ''
    for f in grc grcat; do
      substituteInPlace $f \
        --replace /usr/local/ $out/
    done

    # Support for absolute store paths.
    substituteInPlace grc.conf \
      --replace "^([/\w\.]+\/)" "^([/\w\.\-]+\/)"
  '';

  nativeBuildInputs = [ installShellFiles ];

  installPhase = ''
    runHook preInstall

    ./install.sh "$out" "$out"
    installShellCompletion --zsh --name _grc _grc

    runHook postInstall
  '';

  pyproject = false;

  meta = {
    description = "Generic text colouriser";

    longDescription = ''
      Generic Colouriser is yet another colouriser (written in Python) for
      beautifying your logfiles or output of commands.
    '';

    homepage = "http://kassiopeia.juls.savba.sk/~garabik/software/grc.html";
    license = lib.licenses.gpl2Plus;

    maintainers = with lib.maintainers; [
      peterhoeg
    ];

    platforms = lib.platforms.unix;
    mainProgram = "grc";
  };
})
