{
  lib,
  fetchFromGitHub,
  buildGoModule,
}:

buildGoModule (finalAttrs: {
  pname = "2fa";
  version = "1.2.0";

  src = fetchFromGitHub {
    owner = "rsc";
    repo = "2fa";
    rev = "v${finalAttrs.version}";
    sha256 = "sha256-cB5iADZwvJQwwK1GockE2uicFlqFMEAY6xyeXF5lnUY=";
  };

  vendorHash = "sha256-4h/+ZNxlJPYY0Kyu2vDE1pDXxC/kGE5JdnagWVOGzAE=";
  deleteVendor = true;

  ldflags = [
    "-s"
    "-w"
  ];

  meta = {
    description = "Two-factor authentication on the command line";
    homepage = "https://rsc.io/2fa";
    license = lib.licenses.bsd3;
    maintainers = with lib.maintainers; [ rvolosatovs ];
    mainProgram = "2fa";
  };
})
