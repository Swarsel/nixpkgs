{
  name,
  publisher,
  version,
  arch ? "",
  hash ? "",
  sha256 ? "",
}:
let
  archurl = (if arch == "" then "" else "?targetPlatform=${arch}");
in
{
  inherit sha256 hash;
  # The `*.vsix` file is in the end a simple zip file. Force it using .vsix extension
  # so that existing `unpackVsixSetupHook` hooks takes care of the unpacking.
  name = "${publisher}-${name}.vsix";
  url = "https://${publisher}.gallery.vsassets.io/_apis/public/gallery/publisher/${publisher}/extension/${name}/${version}/assetbyname/Microsoft.VisualStudio.Services.VSIXPackage${archurl}";
}
