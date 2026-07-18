{
  lib,
  fetchFromGitHub,
  buildGoModule,
  go,
  makeWrapper,
}:

buildGoModule (finalAttrs: {
  pname = "gow";
  version = "0-unstable-2025-08-13";

  src = fetchFromGitHub {
    owner = "mitranim";
    repo = "gow";
    rev = "466e175ff6996eba082cb86ac7b43fc5f8f9c766";
    hash = "sha256-vfJ6AFkCeyGKWF/a26ulyErCjCng+uHJlLyRfBmtLs0=";
  };

  nativeBuildInputs = [ makeWrapper ];
  vendorHash = "sha256-L7H3tZQXfeDtWLMvxSMf4/Oez8OV5Q+NhKLkJ991sNA=";

  postFixup = ''
    wrapProgram $out/bin/gow --prefix PATH : ${lib.makeBinPath [ go ]}
  '';

  # This is required for wrapProgram.
  allowGoReference = true;

  meta = {
    description = "Missing watch mode for Go commands";
    homepage = "https://github.com/mitranim/gow";
    license = lib.licenses.unlicense;
    maintainers = with lib.maintainers; [ baloo ];
    mainProgram = "gox";
  };
})
