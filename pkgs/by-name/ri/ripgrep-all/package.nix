{
  lib,
  fetchFromGitHub,
  ffmpeg,
  fzf,
  makeWrapper,
  pandoc,
  poppler-utils,
  ripgrep,
  rustPlatform,
  zip,
}:

let
  path = [
    ffmpeg
    pandoc
    poppler-utils
    ripgrep
    zip
    fzf
  ];
in
rustPlatform.buildRustPackage (finalAttrs: {
  pname = "ripgrep-all";
  version = "0.10.10";

  src = fetchFromGitHub {
    owner = "phiresky";
    repo = "ripgrep-all";
    rev = "v${finalAttrs.version}";
    hash = "sha256-fDSetB2UGzth+3KkCKsXUHj3y08RSfQ2nCKDa8OurW4=";
  };

  nativeBuildInputs = [
    makeWrapper
    poppler-utils
  ];

  cargoHash = "sha256-v+lLCI2ti/xL8hcGkm/xDDN9qk0G9MgtijE8xYnhC68=";
  # override debug=true set in Cargo.toml upstream
  env.RUSTFLAGS = "-C debuginfo=none";
  nativeCheckInputs = path;

  postInstall = ''
    for bin in $out/bin/*; do
      wrapProgram $bin \
        --prefix PATH ":" "${lib.makeBinPath path}"
    done
  '';

  meta = {
    description = "Ripgrep, but also search in PDFs, E-Books, Office documents, zip, tar.gz, and more";

    longDescription = ''
      Ripgrep, but also search in PDFs, E-Books, Office documents, zip, tar.gz, etc.

      rga is a line-oriented search tool that allows you to look for a regex in
      a multitude of file types. rga wraps the awesome ripgrep and enables it
      to search in pdf, docx, sqlite, jpg, movie subtitles (mkv, mp4), etc.
    '';

    homepage = "https://github.com/phiresky/ripgrep-all";
    changelog = "https://github.com/phiresky/ripgrep-all/blob/${finalAttrs.src.rev}/CHANGELOG.md";
    license = with lib.licenses; [ agpl3Plus ];

    maintainers = with lib.maintainers; [
      zaninime
      ma27
    ];

    mainProgram = "rga";
  };
})
