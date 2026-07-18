{ lib, vscode-utils }:

vscode-utils.buildVscodeMarketplaceExtension {
  mktplcRef = {
    version = "0.4.1";
    hash = "sha256-7eMVniepE4lDLAYsMpE5bKYvkfskGaOapxYUJy58mJA=";
    name = "lldb-dap";
    publisher = "llvm-vs-code-extensions";
  };

  meta = {
    description = "Debugging with LLDB in Visual Studio Code";
    homepage = "https://github.com/llvm/llvm-project";
    license = lib.licenses.asl20;
    maintainers = [ lib.maintainers.m0nsterrr ];
    downloadPage = "https://marketplace.visualstudio.com/items?itemName=llvm-vs-code-extensions.lldb-dap";
  };
}
