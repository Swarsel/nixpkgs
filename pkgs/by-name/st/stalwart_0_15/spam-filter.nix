{
  lib,
  stdenv,
  fetchFromGitHub,
  nix-update-script,
  stalwart_0_15,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "spam-filter";
  version = "2.0.5";

  src = fetchFromGitHub {
    owner = "stalwartlabs";
    repo = "spam-filter";
    tag = "v${finalAttrs.version}";
    hash = "sha256-2D/0mnkV4G/Gyr48rbMGTo6uTL7pe+AT+DNKqkBTIbA=";
  };

  buildPhase = ''
    bash ./build.sh
  '';

  installPhase = ''
    mkdir -p $out
    cp spam-filter.toml $out/
  '';

  __structuredAttrs = true;

  passthru = {
    updateScript = nix-update-script { };
  };

  meta = {
    inherit (stalwart_0_15.meta) maintainers;
    description = "Spam filter module for the Stalwart server";
    homepage = "https://github.com/stalwartlabs/spam-filter";
    changelog = "https://github.com/stalwartlabs/spam-filter/blob/${finalAttrs.src.tag}/CHANGELOG.md";

    license = with lib.licenses; [
      mit
      asl20
    ];
  };
})
