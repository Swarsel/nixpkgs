{
  lib,
  fetchFromGitHub,
  bubblewrap,
  makeWrapper,
  oniguruma,
  pkg-config,
  rustPlatform,
}:

rustPlatform.buildRustPackage (finalAttrs: {
  pname = "pipr";
  version = "0.0.16";

  src = fetchFromGitHub {
    owner = "ElKowar";
    repo = "pipr";
    rev = "v${finalAttrs.version}";
    sha256 = "sha256-6jtUNhib6iveuZ7qUKK7AllyMKFpZ8OUUaIieFqseY8=";
  };

  nativeBuildInputs = [
    pkg-config
    makeWrapper
  ];

  buildInputs = [ oniguruma ];
  cargoHash = "sha256-SRIv/dZcyKm2E7c5/LtMCDnh+SDqPhJ01GZtkj0RgA0=";
  # use system oniguruma since the bundled one fails to build with gcc15
  env.RUSTONIG_SYSTEM_LIBONIG = 1;

  postFixup = ''
    wrapProgram "$out/bin/pipr" --prefix PATH : ${lib.makeBinPath [ bubblewrap ]}
  '';

  meta = {
    description = "Commandline-tool to interactively write shell pipelines";
    homepage = "https://github.com/ElKowar/pipr";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ elkowar ];
    platforms = lib.platforms.all;
    mainProgram = "pipr";
  };
})
