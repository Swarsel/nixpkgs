{
  lib,
  stdenv,
  fetchFromCodeberg,
  fetchpatch,
  hareHook,
  nix-update-script,
  scdoc,
}:
stdenv.mkDerivation (finalAttrs: {
  pname = "hare-toml";
  version = "0.2.1";

  src = fetchFromCodeberg {
    owner = "lunacb";
    repo = "hare-toml";
    tag = "v${finalAttrs.version}";
    hash = "sha256-PAXK7BHPzmZaTm3PIbTTn0ZB/8l6HzOkJ2prARxD9UE=";
  };

  nativeBuildInputs = [
    scdoc
    hareHook
  ];

  makeFlags = [ "PREFIX=${placeholder "out"}" ];
  doCheck = true;
  checkTarget = "check_local";
  dontConfigure = true;
  passthru.updateScript = nix-update-script { };

  meta = {
    inherit (hareHook.meta) platforms badPlatforms;
    description = "TOML implementation for Hare";
    homepage = "https://codeberg.org/lunacb/hare-toml";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ onemoresuza ];
  };
})
