{
  lib,
  stdenv,
  fetchFromGitHub,
  buildGoModule,
  cmake,
  datadog-agent,
  hostname,
  makeWrapper,
  pkg-config,
  pythonPackages,
  systemd,
  testers,
  extraTags ? [ ],
  withDocker ? true,
  withSystemd ? lib.meta.availableOn stdenv.hostPlatform systemd,
}:

let
  # keep this in sync with github.com/DataDog/agent-payload dependency
  payloadVersion = "5.0.164";
  python = pythonPackages.python;
  owner = "DataDog";
  repo = "datadog-agent";
  goPackagePath = "github.com/${owner}/${repo}";
  version = "7.75.0";

  src = fetchFromGitHub {
    inherit owner repo;
    tag = version;
    hash = "sha256-oj4LFQiaEeSHcSx0Bar4vU7w/8gi0fgBGSAUjaD4SFc=";
  };
  rtloader = stdenv.mkDerivation {
    inherit version;
    pname = "datadog-agent-rtloader";
    src = "${src}/rtloader";
    nativeBuildInputs = [ cmake ];
    buildInputs = [ python ];

    cmakeFlags = [
      "-DBUILD_DEMO=OFF"
      "-DDISABLE_PYTHON2=ON"
    ];
  };

in
buildGoModule rec {
  inherit src version;
  pname = "datadog-agent";

  # DataDog use paths relative to the agent binary, so fix these.
  # We can't just point these to $out since that would introduce self-referential paths in the go modules,
  # which are a fixed-output derivation. However, the patches aren't picked up if we skip them when building
  # the modules. So we'll just traverse from the bin back to the out folder.
  postPatch = ''
    sed -e "s|PyChecksPath =.*|PyChecksPath = filepath.Join(_here, \"..\", \"${python.sitePackages}\")|" \
        -e "s|distPath =.*|distPath = filepath.Join(_here, \"..\", \"share\", \"datadog-agent\")|" \
        -i pkg/util/defaultpaths/path_nix.go
    sed -e "s|/bin/hostname|${lib.getBin hostname}/bin/hostname|" \
        -i pkg/util/hostname/fqdn_nix.go
  '';

  nativeBuildInputs = [
    pkg-config
    makeWrapper
  ];

  buildInputs = [ rtloader ] ++ lib.optionals withSystemd [ systemd ];
  vendorHash = "sha256-5lqWfhMXrYyZkP/MYH/Uvgu0VHaDmYMOmBOc5xExLi4=";
  env.PKG_CONFIG_PATH = "${python}/lib/pkgconfig";
  doCheck = false;

  # Install the config files and python modules from the "dist" dir
  # into standard paths.
  postInstall = ''
    mkdir -p $out/${python.sitePackages} $out/share/datadog-agent
    cp -R --no-preserve=mode $src/cmd/agent/dist/conf.d $out/share/datadog-agent
    rm -rf $out/share/datadog-agent/conf.d/{apm.yaml.default,process_agent.yaml.default,winproc.d,agentcrashdetect.d,myapp.d}
    cp -R $src/cmd/agent/dist/{checks,utils,config.py} $out/${python.sitePackages}

    wrapProgram "$out/bin/agent" \
      --set PYTHONPATH "$out/${python.sitePackages}"''
  + lib.optionalString withSystemd " --prefix LD_LIBRARY_PATH : ${
     lib.makeLibraryPath [
       (lib.getLib systemd)
       rtloader
     ]
   }";

  ldflags = [
    "-X ${goPackagePath}/pkg/version.Commit=${src.rev}"
    "-X ${goPackagePath}/pkg/version.AgentVersion=${version}"
    "-X ${goPackagePath}/pkg/serializer.AgentPayloadVersion=${payloadVersion}"
    "-X ${goPackagePath}/pkg/collector/python.pythonHome3=${python}"
    "-X ${goPackagePath}/pkg/config/setup.DefaultPython=3"
    "-r ${python}/lib"
  ];

  proxyVendor = true;

  subPackages = [
    "cmd/agent"
    "cmd/cluster-agent"
    "cmd/dogstatsd"
    "cmd/trace-agent"
  ];

  tags = [
    "ec2"
    "kubelet"
    "python"
    "process"
    "log"
    "secrets"
    "zlib"
  ]
  ++ lib.optionals withSystemd [ "systemd" ]
  ++ lib.optionals withDocker [ "docker" ]
  ++ extraTags;

  passthru.tests.version = testers.testVersion {
    command = "agent version";
    package = datadog-agent;
  };

  meta = {
    description = ''
      Event collector for the DataDog analysis service
      -- v6 new golang implementation.
    '';

    homepage = "https://www.datadoghq.com";
    license = lib.licenses.bsd3;

    maintainers = with lib.maintainers; [
      thoughtpolice
    ];
  };
}
