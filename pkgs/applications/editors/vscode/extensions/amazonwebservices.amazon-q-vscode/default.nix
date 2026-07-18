{
  lib,
  vscode-utils,
}:

vscode-utils.buildVscodeMarketplaceExtension (finalAttrs: {
  mktplcRef = {
    version = "2.3.0";
    hash = "sha256-2EEhGU+I61yiVvPEIJlQUgTej9Oi7jW3n5znN2Y2vP4=";
    name = "amazon-q-vscode";
    publisher = "AmazonWebServices";
  };

  meta = {
    # changelog = "https://github.com/aws/aws-toolkit-vscode/releases/tag/amazonq%2Fv${finalAttrs.version}";
    description = "Amazon Q, CodeCatalyst, Local Lambda debug, SAM/CFN syntax, ECS Terminal, AWS resources";
    homepage = "https://github.com/aws/aws-toolkit-vscode";
    license = lib.licenses.asl20;
    maintainers = [ ];
    downloadPage = "https://marketplace.visualstudio.com/items?itemName=AmazonWebServices.amazon-q-vscode";
  };
})
