{
  lib,
  fetchFromGitHub,
  bat,
  coreutils,
  fzf,
  gawk,
  gh,
  gnused,
  makeBinaryWrapper,
  nix-update-script,
  stdenvNoCC,
  withBat ? false,
}:

stdenvNoCC.mkDerivation (finalAttrs: {
  pname = "gh-f";
  version = "1.9.0";

  src = fetchFromGitHub {
    owner = "gennaro-tedesco";
    repo = "gh-f";
    tag = "v${finalAttrs.version}";
    hash = "sha256-QWk9bGjfsIFa/0kAmA2QUmk87iyHdlvblYxML5XmbJ8=";
  };

  nativeBuildInputs = [ makeBinaryWrapper ];

  installPhase = ''
    runHook preInstall

    install -D -m755 "gh-f" "$out/bin/gh-f"

    runHook postInstall
  '';

  postFixup = ''
    wrapProgram "$out/bin/gh-f" \
      --suffix PATH : ${lib.makeBinPath finalAttrs.propagatedUserEnvPkgs}
  '';

  propagatedUserEnvPkgs = [
    gh
    fzf
    coreutils
    gawk
    gnused
  ]
  ++ lib.optional withBat bat;

  passthru.updateScript = nix-update-script { };

  meta = {
    description = "GitHub CLI ultimate FZF extension";
    homepage = "https://github.com/gennaro-tedesco/gh-f";
    license = lib.licenses.unlicense;

    maintainers = with lib.maintainers; [
      loicreynier
      yiyu
    ];

    platforms = lib.platforms.all;
    mainProgram = "gh-f";
  };
})
