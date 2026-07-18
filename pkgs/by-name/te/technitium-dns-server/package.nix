{
  lib,
  fetchFromGitHub,
  buildDotnetModule,
  dotnetCorePackages,
  libmsquic,
  nix-update-script,
  nixosTests,
  technitium-dns-server-library,
}:
buildDotnetModule rec {
  pname = "technitium-dns-server";
  version = "15.3.0";

  src = fetchFromGitHub {
    owner = "TechnitiumSoftware";
    repo = "DnsServer";
    tag = "v${version}";
    hash = "sha256-nopmnQpozvN0p/SyUCH3Yej/oAhDvNdfJssUA1JyGsk=";
    name = "${pname}-${version}";
  };

  # move dependencies from TechnitiumLibrary to the expected directory
  preBuild = ''
    mkdir -p ../TechnitiumLibrary/bin
    cp -r ${technitium-dns-server-library}/lib/${technitium-dns-server-library.pname}/* ../TechnitiumLibrary/bin/
  '';

  postFixup = ''
    mv $out/bin/DnsServerApp $out/bin/technitium-dns-server
  '';

  dotnet-runtime = dotnetCorePackages.aspnetcore_10_0;
  dotnet-sdk = dotnetCorePackages.sdk_10_0;
  nugetDeps = ./nuget-deps.json;
  projectFile = [ "DnsServerApp/DnsServerApp.csproj" ];

  runtimeDeps = [
    libmsquic
  ];

  passthru.tests = {
    inherit (nixosTests) technitium-dns-server;
  };

  passthru.updateScript = nix-update-script { };

  meta = {
    description = "Authorative and Recursive DNS server for Privacy and Security";
    homepage = "https://github.com/TechnitiumSoftware/DnsServer";
    changelog = "https://github.com/TechnitiumSoftware/DnsServer/blob/master/CHANGELOG.md";
    license = lib.licenses.gpl3Only;

    maintainers = with lib.maintainers; [
      fabianrig
      awildleon
    ];

    platforms = lib.platforms.linux;
    mainProgram = "technitium-dns-server";
  };
}
