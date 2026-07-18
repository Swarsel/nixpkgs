{
  lib,
  fetchFromGitHub,
  buildDotnetModule,
  dotnetCorePackages,
  nix-update-script,
}:
buildDotnetModule rec {
  pname = "technitium-dns-server-library";
  version = "15.3.0";

  src = fetchFromGitHub {
    owner = "TechnitiumSoftware";
    repo = "TechnitiumLibrary";
    tag = "dns-server-v${version}";
    hash = "sha256-BQWDzMEiChY8uX1wUUZNWFDomGqUyDrZ6+UEncC5G5U=";
    name = "${pname}-${version}";
  };

  dotnet-sdk = dotnetCorePackages.sdk_10_0;
  nugetDeps = ./nuget-deps.json;

  projectFile = [
    "TechnitiumLibrary.ByteTree/TechnitiumLibrary.ByteTree.csproj"
    "TechnitiumLibrary.Net/TechnitiumLibrary.Net.csproj"
    "TechnitiumLibrary.Security.OTP/TechnitiumLibrary.Security.OTP.csproj"
  ];

  passthru.updateScript = nix-update-script { };

  meta = {
    description = "Library for Authorative and Recursive DNS server for Privacy and Security";
    homepage = "https://github.com/TechnitiumSoftware/DnsServer";
    changelog = "https://github.com/TechnitiumSoftware/DnsServer/blob/master/CHANGELOG.md";
    license = lib.licenses.gpl3Only;

    maintainers = with lib.maintainers; [
      fabianrig
      awildleon
    ];

    platforms = lib.platforms.linux;
    mainProgram = "technitium-dns-server-library";
  };
}
