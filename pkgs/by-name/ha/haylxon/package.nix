{
  lib,
  fetchCrate,
  rustPlatform,
}:

rustPlatform.buildRustPackage (finalAttrs: {
  pname = "haylxon";
  version = "1.2.1";

  src = fetchCrate {
    inherit (finalAttrs) version;
    hash = "sha256-L1Xd6u4B8DR9jR//FNloiOzzXiLnWP+580izP2NVvoY=";
    pname = "hxn";
  };

  cargoHash = "sha256-aQSn3LT0gNQWXrPWVe/ulP446Dk9o1N0OGka3gGhNYg=";

  meta = {
    description = "Save screenshots of urls and webpages from terminal";
    homepage = "https://github.com/pwnwriter/haylxon";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ scientiac ];
    mainProgram = "hxn";
  };
})
