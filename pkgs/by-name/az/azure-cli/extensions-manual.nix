# Manually packaged extensions for azure-cli
#
# Checkout ./README.md for more information.

{
  lib,
  autoPatchelfHook,
  config,
  mkAzExtension,
  mycli,
  openssl,
  python3,
  python3Packages,
}:

{
  acrcssc = mkAzExtension {
    pname = "acrcssc";
    version = "1.0.0b5";

    propagatedBuildInputs = with python3Packages; [
      croniter
      oras
    ];

    description = "Microsoft Azure Container Registry Container Secure Supply Chain (CSSC) Extension";
    hash = "sha256-Z3wi+/3UK+TUKHE7MCSP/Es8ViGVTrlcafojw2YFRBs=";
    url = "https://azcliprod.blob.core.windows.net/cli-extensions/acrcssc-1.0.0b5-py3-none-any.whl";
    meta.maintainers = with lib.maintainers; [ techknowlogick ];
  };

  aksarc = mkAzExtension {
    pname = "aksarc";
    version = "1.5.62";

    propagatedBuildInputs = with python3Packages; [
      kubernetes
      paramiko
    ];

    description = "Microsoft Azure Command-Line Tools HybridContainerService Extension";
    hash = "sha256-PCy4SUbB4Vlj+fIwhufGwMJrrRehQr/W+QxAphTPnEk=";
    url = "https://hybridaksstorage.z13.web.core.windows.net/HybridAKS/CLI/aksarc-1.5.62-py3-none-any.whl";
    meta.maintainers = with lib.maintainers; [ techknowlogick ];
  };

  alias = mkAzExtension rec {
    pname = "alias";
    version = "0.5.2";

    propagatedBuildInputs = with python3Packages; [
      jinja2
    ];

    description = "Support for command aliases";
    hash = "sha256-BfgtdQJueA0nvTShvlf07A9CVQDYq07n6S/uB7lE2jM=";
    url = "https://azcliprod.blob.core.windows.net/cli-extensions/alias-${version}-py2.py3-none-any.whl";
    meta.maintainers = with lib.maintainers; [ techknowlogick ];
  };

  aosm = mkAzExtension rec {
    pname = "aosm";
    version = "2.0.0b2";

    propagatedBuildInputs = with python3Packages; [
      genson
      jinja2
      oras
      ruamel-yaml
    ];

    description = "Microsoft Azure Command-Line Tools Aosm Extension";
    hash = "sha256-nK752/alBu0JYax8B+sp6oByPISqYGIgL6KFX5AIJmk=";
    url = "https://azcliprod.blob.core.windows.net/cli-extensions/aosm-${version}-py2.py3-none-any.whl";
    meta.maintainers = with lib.maintainers; [ techknowlogick ];
  };

  application-insights = mkAzExtension rec {
    pname = "application-insights";
    version = "2.0.0b1";
    propagatedBuildInputs = with python3Packages; [ isodate ];
    description = "Support for managing Application Insights components and querying metrics, events, and logs from such components";
    hash = "sha256-4akS+zbaKxFrs0x0uKP/xX28WyK5KLduOkgZaBYeANM=";
    pythonRelaxDeps = [ "isodate" ];
    url = "https://azcliprod.blob.core.windows.net/cli-extensions/application_insights-${version}-py2.py3-none-any.whl";
    meta.maintainers = with lib.maintainers; [ andreasvoss ];
  };

  arcappliance = mkAzExtension {
    pname = "arcappliance";
    version = "1.6.0";

    propagatedBuildInputs = with python3Packages; [
      jsonschema
      kubernetes
    ];

    description = "Microsoft Azure Command-Line Tools Arcappliance Extension";
    hash = "sha256-1VTKp4R6ohI4C9QsZgAabJJMnkTycEQF7DDshw/7Qkw=";
    url = "https://arcplatformcliextprod.z13.web.core.windows.net/arcappliance-1.6.0-py2.py3-none-any.whl";
    meta.maintainers = with lib.maintainers; [ techknowlogick ];
  };

  arcdata = mkAzExtension {
    pname = "arcdata";
    version = "1.5.25";

    propagatedBuildInputs = with python3Packages; [
      jinja2
      jsonpatch
      jsonpath-ng
      jsonschema
      kubernetes
      ndjson
      pem
      pydash
      regex
    ];

    description = "Tools for managing ArcData";
    hash = "sha256-/ejgjd/O37GtS6/+gzsscImoLllaDYCl2LS8m+pulTw=";
    url = "https://azurearcdatacli.z13.web.core.windows.net/arcdata-1.5.25-py2.py3-none-any.whl";
    meta.maintainers = with lib.maintainers; [ techknowlogick ];
  };

  attestation = mkAzExtension {
    pname = "attestation";
    version = "1.0.0";

    propagatedBuildInputs = with python3Packages; [
      pyjwt
    ];

    description = "Microsoft Azure Command-Line Tools AttestationManagementClient Extension";
    hash = "sha256-5YJ3wpIhTjsKHmbeXFI0De3yX1x8NWRgsgJZ1frO70Y=";
    url = "https://azcliprod.blob.core.windows.net/cli-extensions/attestation-1.0.0-py3-none-any.whl";
    meta.maintainers = with lib.maintainers; [ techknowlogick ];
  };

  azure-devops = mkAzExtension rec {
    pname = "azure-devops";
    version = "1.0.6";
    propagatedBuildInputs = with python3Packages; [ distro ];
    description = "Tools for managing Azure DevOps";
    hash = "sha256-+neeH9bm4bcmw2VrahloU3wggEHGr1TSp0dnctiWs0s=";
    url = "https://github.com/Azure/azure-cli-extensions/releases/download/azure-devops-${version}/azure_devops-${version}-py2.py3-none-any.whl";
    meta.maintainers = with lib.maintainers; [ katexochen ];
  };

  azure-iot = mkAzExtension rec {
    pname = "azure-iot";
    version = "0.25.0";

    propagatedBuildInputs = (
      with python3Packages;
      [
        azure-core
        azure-identity
        azure-iot-device
        azure-mgmt-core
        azure-storage-blob
        jsonschema
        msrest
        msrestazure
        packaging
        tomli
        tomli-w
        tqdm
        treelib
      ]
    );

    description = "Azure IoT extension for Azure CLI";
    hash = "sha256-fbS8B2Z++oRyUT2eEh+yVR/K6uaCVce8B2itQXfBscY=";
    url = "https://github.com/Azure/azure-iot-cli-extension/releases/download/v${version}/azure_iot-${version}-py3-none-any.whl";
    meta.maintainers = with lib.maintainers; [ mikut ];
  };

  cloud-service = mkAzExtension {
    pname = "cloud-service";
    version = "1.0.1";

    propagatedBuildInputs = with python3Packages; [
      azure-mgmt-compute
    ];

    description = "Microsoft Azure Command-Line Tools ComputeManagementClient Extension";
    hash = "sha256-9rLYCn6rO6vTGFdBtGfgHQwceKbtf/t48DG4dQBzc+Q=";
    url = "https://azcliprod.blob.core.windows.net/cli-extensions/cloud_service-1.0.1-py3-none-any.whl";
    meta.maintainers = with lib.maintainers; [ techknowlogick ];
  };

  confcom = mkAzExtension rec {
    pname = "confcom";
    version = "2.1.0";
    nativeBuildInputs = [ autoPatchelfHook ];
    buildInputs = [ openssl ];

    propagatedBuildInputs = with python3Packages; [
      deepdiff
      docker
      pydantic
      pyyaml
      tqdm
    ];

    postInstall = ''
      chmod +x $out/${python3.sitePackages}/azext_confcom/bin/genpolicy-linux
    '';

    description = "Microsoft Azure Command-Line Tools Confidential Container Security Policy Generator Extension";
    hash = "sha256-mcUYTxpjounvP2500nFgXF+WKERJdLuYXb6zt31v4NA=";
    pythonRelaxDeps = [ "tqdm" ];
    url = "https://azcliprod.blob.core.windows.net/cli-extensions/confcom-${version}-py3-none-any.whl";

    meta = {
      maintainers = [ ];
      platforms = lib.platforms.linux; # confcom is linux only
    };
  };

  connectedk8s = mkAzExtension rec {
    pname = "connectedk8s";
    version = "1.11.0";

    propagatedBuildInputs = with python3Packages; [
      azure-graphrbac
      azure-mgmt-hybridcompute
      kubernetes
      oras
      pycryptodome
      pyyaml
    ];

    description = "Microsoft Azure Command-Line Tools Connectedk8s Extension";
    hash = "sha256-Hl/+mS1Aj5Vsq2VFWrJuYmhXglt/wCr0ld67tK+tMak=";
    url = "https://azcliprod.blob.core.windows.net/cli-extensions/connectedk8s-${version}-py2.py3-none-any.whl";
    meta.maintainers = with lib.maintainers; [ techknowlogick ];
  };

  containerapp = mkAzExtension rec {
    pname = "containerapp";
    version = "1.3.0b2";

    propagatedBuildInputs = with python3Packages; [
      docker
      pycomposefile
      kubernetes
    ];

    description = "Microsoft Azure Command-Line Tools Containerapp Extension";
    hash = "sha256-Br/cfKFTkqcjGRCXAbHqfwTe4g49F3zbj/tzp/O+giI=";
    url = "https://azcliprod.blob.core.windows.net/cli-extensions/containerapp-${version}-py2.py3-none-any.whl";
    meta.maintainers = with lib.maintainers; [ giggio ];
  };

  interactive = mkAzExtension {
    pname = "interactive";
    version = "1.0.0b1";

    propagatedBuildInputs = with python3Packages; [
      prompt-toolkit
    ];

    description = "Microsoft Azure Command-Line Interactive Shell";
    hash = "sha256-COvHDhvsigEEMYlMQ2hHFKzjX7WwdkwfT9id6z+Sj7w=";

    # The wheel contains Requires-Dist entries for both spellings.
    pythonRelaxDeps = [
      "prompt_toolkit"
      "prompt-toolkit"
    ];

    url = "https://azcliprod.blob.core.windows.net/cli-extensions/interactive-1.0.0b1-py2.py3-none-any.whl";
    meta.maintainers = with lib.maintainers; [ techknowlogick ];
  };

  k8s-configuration = mkAzExtension rec {
    pname = "k8s-configuration";
    version = "2.3.0";

    propagatedBuildInputs = with python3Packages; [
      pycryptodome
      pyyaml
    ];

    description = "Microsoft Azure Command-Line Tools K8s-configuration Extension";
    hash = "sha256-ABkAYL19wQIiB+xuu2y/9otpSh/SSxgbuXhv5RrHP2c=";
    url = "https://azcliprod.blob.core.windows.net/cli-extensions/k8s_configuration-${version}-py3-none-any.whl";
    meta.maintainers = with lib.maintainers; [ techknowlogick ];
  };

  k8s-extension = mkAzExtension rec {
    pname = "k8s-extension";
    version = "1.7.0";

    propagatedBuildInputs = with python3Packages; [
      kubernetes
      oras
    ];

    description = "Microsoft Azure Command-Line Tools K8s-extension Extension";
    hash = "sha256-gyQxHfsXd+V6w2jMBNiYpE1MrqFeHei9RlsVhXgOjW8=";
    url = "https://azcliprod.blob.core.windows.net/cli-extensions/k8s_extension-${version}-py3-none-any.whl";
    meta.maintainers = [ ];
  };

  rdbms-connect = mkAzExtension rec {
    pname = "rdbms-connect";
    version = "1.0.7";

    propagatedBuildInputs =
      (with python3Packages; [
        pgcli
        psycopg2
        pymysql
        setproctitle
      ])
      ++ [ mycli ];

    description = "Support for testing connection to Azure Database for MySQL & PostgreSQL servers";
    hash = "sha256-66mX1K1azQvbuApyKBwvVuiKCbLaqezCDdrv0lhvVD0=";

    pythonRelaxDeps = [
      "mycli"
      "pgcli"
    ];

    url = "https://azcliprod.blob.core.windows.net/cli-extensions/rdbms_connect-${version}-py2.py3-none-any.whl";
    meta.maintainers = with lib.maintainers; [ obreitwi ];
  };

  redisenterprise = mkAzExtension rec {
    pname = "redisenterprise";
    version = "1.4.0";

    propagatedBuildInputs = with python3Packages; [
      redis
      pyjwt
    ];

    description = "Microsoft Azure Command-Line Tools RedisEnterprise Extension";
    hash = "sha256-vMKLLC/q39SZ2MbqxmcjUiylr01D1olaLujQ1LbFqak=";
    url = "https://azcliprod.blob.core.windows.net/cli-extensions/redisenterprise-${version}-py3-none-any.whl";
  };

  serial-console = mkAzExtension {
    pname = "serial-console";
    version = "1.0.0b2";

    propagatedBuildInputs = with python3Packages; [
      websocket-client
    ];

    description = "Microsoft Azure Command-Line Tools for Serial Console Extension";
    hash = "sha256-Weu4BEdq/0dvi07682UfYL8FzAd3cKZUGVJLTzJ27JM=";
    url = "https://azcliprod.blob.core.windows.net/cli-extensions/serial_console-1.0.0b2-py3-none-any.whl";
    meta.maintainers = with lib.maintainers; [ techknowlogick ];
  };

  ssh = mkAzExtension rec {
    pname = "ssh";
    version = "2.0.9";

    propagatedBuildInputs = with python3Packages; [
      oras
      oschmod
    ];

    description = "SSH into Azure VMs using RBAC and AAD OpenSSH Certificates";
    hash = "sha256-OdE4FZckAeM0eFI5/QPBtLJnCIs7fQF/M47B7ULqxFY=";
    pythonRelaxDeps = true;
    url = "https://azcliprod.blob.core.windows.net/cli-extensions/ssh-${version}-py3-none-any.whl";

    meta = {
      changelog = "https://github.com/Azure/azure-cli-extensions/blob/ssh-${version}/src/ssh/HISTORY.md";
      maintainers = with lib.maintainers; [ gordon-bp ];
    };
  };

  storage-preview = mkAzExtension rec {
    pname = "storage-preview";
    version = "1.0.0b8";
    propagatedBuildInputs = with python3Packages; [ azure-core ];
    description = "Provides a preview for upcoming storage features";
    hash = "sha256-qgDslmBX/XJA5nn95hJJb06vMC3izdbz7qlmQpx74T8=";
    url = "https://azcliprod.blob.core.windows.net/cli-extensions/storage_preview-${version}-py2.py3-none-any.whl";
    meta.maintainers = with lib.maintainers; [ katexochen ];
  };

  vm-repair = mkAzExtension rec {
    pname = "vm-repair";
    version = "2.2.0";
    propagatedBuildInputs = with python3Packages; [ opencensus ];
    description = "Support for repairing Azure Virtual Machines";
    hash = "sha256-ppsK4rJa/nFFkO2XJvjnK0PIRp9/haVwWfqfF7oN5WQ=";
    url = "https://azcliprod.blob.core.windows.net/cli-extensions/vm_repair-${version}-py2.py3-none-any.whl";
    meta.maintainers = [ ];
  };

  webpubsub = mkAzExtension {
    pname = "webpubsub";
    version = "1.7.2";

    propagatedBuildInputs = with python3Packages; [
      websockets
    ];

    description = "Microsoft Azure Command-Line Tools Webpubsub Extension";
    hash = "sha256-axtA9vXM1WmzXTj7rbA6Tlrx7kpx2Z6c3NYtwUiv2UI=";
    url = "https://azcliprod.blob.core.windows.net/cli-extensions/webpubsub-1.7.2-py3-none-any.whl";
    meta.maintainers = with lib.maintainers; [ techknowlogick ];
  };

  workload-orchestration = mkAzExtension {
    pname = "workload-orchestration";
    version = "5.1.1";

    propagatedBuildInputs = with python3Packages; [
      kubernetes
    ];

    description = "Microsoft Azure Command-Line Tools WorkloadOperations Extension";
    hash = "sha256-mtmFRd6K2uOpzgKezdAoBDD7mGFh7blkUGvMqSajdSQ=";
    url = "https://azcliprod.blob.core.windows.net/cli-extensions/workload_orchestration-5.1.1-py3-none-any.whl";
  };
}
// lib.optionalAttrs config.allowAliases {
  # Removed extensions
  adp = throw "The 'adp' extension for azure-cli was deprecated upstream"; # Added 2024-11-02, https://github.com/Azure/azure-cli-extensions/pull/8038
  akshybrid = throw "The 'akshybrid' extension for azure-cli was removed upstream"; # https://github.com/Azure/azure-cli-extensions/pull/8955
  appservice-kube = throw "The 'appservice-kube' extensions for azure-cli was removed upstream"; # https://github.com/Azure/azure-cli-extensions/pull/10036
  azurestackhci = throw "The 'azurestackhci' extension for azure-cli was deprecated upstream"; # Added 2025-07-01, https://github.com/Azure/azure-cli-extensions/pull/8898
  blockchain = throw "The 'blockchain' extension for azure-cli was deprecated upstream"; # Added 2024-04-26, https://github.com/Azure/azure-cli-extensions/pull/7370
  compute-diagnostic-rp = throw "The 'compute-diagnostic-rp' extension for azure-cli was deprecated upstream"; # Added 2024-11-12, https://github.com/Azure/azure-cli-extensions/pull/8240
  connection-monitor-preview = throw "The 'connection-monitor-preview' extension for azure-cli was deprecated upstream"; # Added 2024-11-02, https://github.com/Azure/azure-cli-extensions/pull/8194
  csvmware = throw "The 'csvmware' extension for azure-cli was removed upstream"; # https://github.com/Azure/azure-cli-extensions/pull/8931
  deidservice = throw "The 'deidservice' extension for azure-cli was moved under healthcareapis"; # Added 2024-11-19, https://github.com/Azure/azure-cli-extensions/pull/8224
  fileshares = throw "The 'fileshares' extensions for azure-cli was removed upstream"; # https://github.com/Azure/azure-cli-extensions/pull/9910
  hdinsightonaks = throw "The 'hdinsightonaks' extension for azure-cli was removed upstream"; # https://github.com/Azure/azure-cli-extensions/pull/8956
  logz = throw "The 'logz' extension for azure-cli was deprecated upstream"; # Added 2024-11-02, https://github.com/Azure/azure-cli-extensions/pull/8459
  mobile-network = throw "The 'mobile-network' extension for azure-cli was removed upstream"; # https://github.com/Azure/azure-cli-extensions/pull/9453
  neon = throw "The 'neon' extension for azure-cli was removed upstream"; # Added 2026-04-13, https://github.com/Azure/azure-cli-extensions/pull/9661
  pinecone = throw "The 'pinecone' extension for azure-cli was removed upstream"; # Added 2025-06-03, https://github.com/Azure/azure-cli-extensions/pull/8763
  playwright-cli-extension = throw "The 'playwright-cli-extension' extension for azure-cli was removed upstream"; # https://github.com/Azure/azure-cli-extensions/pull/9156
  sap-hana = throw "The 'sap-hana' extension for azure-cli was deprecated upstream"; # Added 2025-07-01, https://github.com/Azure/azure-cli-extensions/pull/8904
  spring = throw "The 'spring' extension for azure-cli was deprecated upstream"; # Added 2025-05-07, https://github.com/Azure/azure-cli-extensions/pull/8652
  spring-cloud = throw "The 'spring-cloud' extension for azure-cli was deprecated upstream"; # Added 2025-07-01 https://github.com/Azure/azure-cli-extensions/pull/8897
  weights-and-biases = throw "The 'weights-and-biases' extension for azure-cli was removed upstream"; # Added 2025-06-03, https://github.com/Azure/azure-cli-extensions/pull/8764
}
