{
  lib,
  fetchFromGitHub,
  buildDotnetModule,
  dotnetCorePackages,
  nix-update-script,
  versionCheckHook,
}:

let
  pname = "marksman";
  dotnet-sdk = dotnetCorePackages.sdk_9_0_1xx-bin;
in
buildDotnetModule (finalAttrs: {
  inherit pname dotnet-sdk;
  version = "2026-02-08";

  src = fetchFromGitHub {
    owner = "artempyanykh";
    repo = "marksman";
    tag = finalAttrs.version;
    hash = "sha256-xebt55WKHOKwA6QIkW5mnvqUGHeGRzINCWfViA4cfJ0=";
  };

  doCheck = true;

  postInstall = ''
    install -m 644 -D -t "$out/share/doc/${pname}" LICENSE
  '';

  doInstallCheck = true;
  nativeInstallCheckInputs = [ versionCheckHook ];
  __darwinAllowLocalNetworking = true;
  dotnet-runtime = dotnetCorePackages.runtime_9_0;
  dotnetBuildFlags = [ "-p:VersionString=${finalAttrs.version}" ];
  nugetDeps = ./deps.json;
  projectFile = "Marksman/Marksman.fsproj";
  testProjectFile = "Tests/Tests.fsproj";

  passthru = {
    updateScript = nix-update-script { };
  };

  meta = {
    description = "Language Server for Markdown";

    longDescription = ''
      Marksman is a program that integrates with your editor
      to assist you in writing and maintaining your Markdown documents.
      Using LSP protocol it provides completion, goto definition,
      find references, rename refactoring, diagnostics, and more.
      In addition to regular Markdown, it also supports wiki-link-style
      references that enable Zettelkasten-like note taking.
    '';

    homepage = "https://github.com/artempyanykh/marksman";
    license = lib.licenses.mit;

    maintainers = with lib.maintainers; [
      stasjok
      plusgut
    ];

    platforms = dotnet-sdk.meta.platforms;
    mainProgram = "marksman";
  };
})
