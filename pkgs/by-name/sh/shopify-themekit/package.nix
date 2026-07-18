{
  lib,
  fetchFromGitHub,
  buildGoModule,
}:

buildGoModule (finalAttrs: {
  pname = "shopify-themekit";
  version = "1.3.3";

  src = fetchFromGitHub {
    owner = "Shopify";
    repo = "themekit";
    rev = "v${finalAttrs.version}";
    sha256 = "sha256-m0TAgnYklj/WqZJIm9mHLE7SZgXP8YDQZndDgpiNqL0=";
  };

  vendorHash = "sha256-o928qjp7+/U1W03esYTwVEfQ4A3TmPnmgmh4oWpqJoo=";

  postInstall = ''
    # Keep `theme` only
    rm -f $out/bin/{cmd,tkrelease}
  '';

  ldflags = [
    "-s"
    "-w"
  ];

  meta = {
    description = "Command line tool for shopify themes";
    homepage = "https://shopify.github.io/themekit/";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ _1000101 ];
    mainProgram = "theme";
  };
})
