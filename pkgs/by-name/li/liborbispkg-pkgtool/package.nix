{
  lib,
  fetchFromGitHub,
  buildDotnetModule,
}:
buildDotnetModule {
  pname = "liborbispkg-pkgtool";
  version = "0.3-unstable-2025-11-13";

  src = fetchFromGitHub {
    owner = "OpenOrbis";
    repo = "LibOrbisPkg";
    rev = "c1caa3ba25097fe602c0d842a0357bf7037b0838";
    hash = "sha256-bCnaWooLHmUK5Say4fQINUuzTAmXr8qULmkD8bVVUjU=";
  };

  postFixup = ''
    mv $out/bin/PkgTool.Core $out/bin/pkgtool
  '';

  projectFile = "PkgTool.Core/PkgTool.Core.csproj";

  meta = {
    description = "CLI for creating, inspecting, and modifying PS4 PKG, SFO, PFS, and related filetypes";
    homepage = "https://github.com/OpenOrbis/LibOrbisPkg";
    license = lib.licenses.lgpl3Plus;
    maintainers = [ lib.maintainers.ryand56 ];
    mainProgram = "pkgtool";
  };
}
