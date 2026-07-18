{
  lib,
  fetchFromGitHub,
  rustPlatform,
}:

rustPlatform.buildRustPackage (finalAttrs: {
  pname = "microserver";
  version = "0.2.1";

  src = fetchFromGitHub {
    owner = "robertohuertasm";
    repo = "microserver";
    rev = "v${finalAttrs.version}";
    sha256 = "sha256-VgzOdJ1JLe0acjRYvaysCPox5acFmc4VD2f6HZWxT8M=";
  };

  cargoHash = "sha256-IPJJ9kv7gf5l7Y2JLCLjkNFao42h/VmkTd3LF5BCMLU=";

  meta = {
    description = "Simple ad-hoc server with SPA support";
    homepage = "https://github.com/robertohuertasm/microserver";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ flosse ];
    mainProgram = "microserver";
  };
})
