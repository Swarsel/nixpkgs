{
  lib,
  fetchFromGitHub,
  buildNpmPackage,
  ffmpeg,
  flac2mp3,
  sox,
}:

let
  runtimeDeps = [
    ffmpeg
    flac2mp3
    sox
  ];
in
buildNpmPackage (finalAttrs: {
  pname = "red-trul";
  version = "2.3.13";

  src = fetchFromGitHub {
    owner = "lfence";
    repo = "red-trul";
    tag = "v${finalAttrs.version}";
    hash = "sha256-t8P59diMwYKaGuPuNajWDmRU0fBNT6yRwMBLIRfUhTk";
  };

  postPatch = ''
    substituteInPlace config.js \
      --replace-fail '`''${__dirname}/flac2mp3/flac2mp3.pl`' '"flac2mp3"'
    substituteInPlace trul.js \
      --replace-fail "  await fs.access(FLAC2MP3)" ""
  '';

  npmDepsHash = "sha256-BYgNgV0hTkfDByi/86X7ZLcAYKveVDiSKnvUfdjyfHc=";

  postFixup = ''
    wrapProgram $out/bin/red-trul \
      --prefix PATH : ${lib.makeBinPath finalAttrs.passthru.runtimeDeps}
  '';

  dontNpmBuild = true;

  passthru = {
    inherit runtimeDeps;
  };

  meta = {
    description = "Lightweight utility to transcode FLAC releases";
    homepage = "https://github.com/lfence/red-trul";
    changelog = "https://github.com/lfence/red-trul/releases/tag/${finalAttrs.version}";
    license = with lib.licenses; [ isc ];
    maintainers = with lib.maintainers; [ lilahummel ];
    mainProgram = "red-trul";
  };
})
