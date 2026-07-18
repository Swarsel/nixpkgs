{
  lib,
  fetchFromGitHub,
  buildGoModule,
}:

buildGoModule (finalAttrs: {
  pname = "gomodifytags";
  version = "1.17.0";

  src = fetchFromGitHub {
    owner = "fatih";
    repo = "gomodifytags";
    rev = "v${finalAttrs.version}";
    sha256 = "sha256-XVjSRW7FzXbGmGT+xH4tNg9PVXvgmhQXTIrYYZ346/M=";
  };

  vendorHash = "sha256-0eWrkOcaow+W2Daaw2rzugfS+jqhN6RE2iCdpui9aQg=";

  meta = {
    description = "Go tool to modify struct field tags";
    homepage = "https://github.com/fatih/gomodifytags";
    license = lib.licenses.bsd3;
    maintainers = with lib.maintainers; [ vdemeester ];
    mainProgram = "gomodifytags";
  };
})
