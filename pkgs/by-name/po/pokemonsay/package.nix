{
  lib,
  fetchFromGitHub,
  coreutils,
  cowsay,
  fetchpatch,
  findutils,
  stdenvNoCC,
}:

stdenvNoCC.mkDerivation rec {
  pname = "pokemonsay";
  version = "1.0.0";

  src = fetchFromGitHub {
    owner = "HRKings";
    repo = "pokemonsay-newgenerations";
    rev = "v${version}";
    hash = "sha256-IDTAZmOzkUg0kLUM0oWuVbi8EwE4sEpLWrNAtq/he+g=";
  };

  patches = [
    (fetchpatch {
      hash = "sha256-aqUJkyJDWArLjChxLZ4BbC6XAB53LAqARzTvEAxrFCI=";
      # https://github.com/HRKings/pokemonsay-newgenerations/pull/5
      name = "word-wrap-fix.patch";
      url = "https://github.com/pbsds/pokemonsay-newgenerations/commit/7056d7ba689479a8e6c14ec000be1dfcd83afeb0.patch";
    })
  ];

  postPatch = ''
    substituteInPlace pokemonsay.sh \
      --replace-fail \
        'INSTALL_PATH=''${HOME}/.bin/pokemonsay' \
        "" \
      --replace-fail \
        'POKEMON_PATH=''${INSTALL_PATH}/pokemons' \
        'POKEMON_PATH=${placeholder "out"}/share/pokemonsay' \
      --replace-fail \
        '$(find ' \
        '$(${findutils}/bin/find ' \
      --replace-fail \
        '$(basename ' \
        '$(${coreutils}/bin/basename ' \
      --replace-fail \
        'cowsay -f ' \
        '${cowsay}/bin/cowsay -f ' \
      --replace-fail \
        'cowthink -f ' \
        '${cowsay}/bin/cowthink -f '

    substituteInPlace pokemonthink.sh \
      --replace-fail \
        './pokemonsay.sh' \
        "${placeholder "out"}/bin/pokemonsay"
  '';

  installPhase = ''
    mkdir -p $out/{bin,share/pokemonsay}
    cp pokemonsay.sh $out/bin/pokemonsay
    cp pokemonthink.sh $out/bin/pokemonthink
    cp pokemons/*.cow $out/share/pokemonsay
  '';

  doInstallCheck = true;

  installCheckPhase = ''
    (set -x
      test "$($out/bin/pokemonsay --list | wc -l)" -ge 891
    )
  '';

  meta = {
    description = "Print pokemon in the CLI! An adaptation of the classic cowsay";
    homepage = "https://github.com/HRKings/pokemonsay-newgenerations";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ pbsds ];
    platforms = lib.platforms.all;
  };
}
