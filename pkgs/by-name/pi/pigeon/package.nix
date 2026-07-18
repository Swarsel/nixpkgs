{
  lib,
  fetchFromGitHub,
  buildGoModule,
}:

buildGoModule (finalAttrs: {
  pname = "pigeon";
  version = "1.3.0";

  src = fetchFromGitHub {
    owner = "mna";
    repo = "pigeon";
    rev = "v${finalAttrs.version}";
    hash = "sha256-rEkeB5NI51dsLOxd9RnJWmfUP78owOJl6j9t3nz277s=";
  };

  vendorHash = "sha256-vaCgvj/n8MuktaZ2+tQVlQW0LrptQkEQK2qM+YwXXhg=";
  doCheck = false;
  proxyVendor = true;
  subPackages = [ "." ];

  meta = {
    description = "PEG parser generator for Go";
    homepage = "https://github.com/mna/pigeon";
    license = with lib.licenses; [ bsd3 ];
    maintainers = with lib.maintainers; [ zimbatm ];
    mainProgram = "pigeon";
  };
})
