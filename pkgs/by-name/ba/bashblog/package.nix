{
  lib,
  stdenv,
  fetchFromGitHub,
  makeWrapper,
  pandoc,
  perlPackages,
  replaceVars,
  # Flags to enable processors
  # Currently, Markdown.pl does not work
  usePandoc ? true,
}:

let
  inherit (perlPackages) TextMarkdown;
  # As bashblog supports various markdown processors
  # we can set flags to enable a certain processor
  markdownpl_path = "${perlPackages.TextMarkdown}/bin/Markdown.pl";
  pandoc_path = "${pandoc}/bin/pandoc";

in
stdenv.mkDerivation {
  pname = "bashblog";
  version = "0-unstable-2022-03-26";

  src = fetchFromGitHub {
    owner = "cfenollosa";
    repo = "bashblog";
    rev = "c3d4cc1d905560ecfefce911c319469f7a7ff8a8";
    sha256 = "sha256-THlP/JuaZzDq9QctidwLRiUVFxRhGNhRKleWbQiqsgg=";
  };

  patches = [
    (replaceVars ./0001-Setting-markdown_bin.patch {
      markdown_path = if usePandoc then pandoc_path else markdownpl_path;
    })
  ];

  postPatch = ''
    patchShebangs bb.sh
  '';

  nativeBuildInputs = [ makeWrapper ];
  buildInputs = [ TextMarkdown ] ++ lib.optionals usePandoc [ pandoc ];

  installPhase = ''
    runHook preInstall

    mkdir -p $out/bin
    install -Dm755 bb.sh $out/bin/bashblog

    runHook postInstall
  '';

  meta = {
    description = "Single Bash script to create blogs";
    homepage = "https://github.com/cfenollosa/bashblog";
    license = lib.licenses.gpl3Only;
    maintainers = [ ];
    platforms = lib.platforms.unix;
    mainProgram = "bashblog";
  };
}
