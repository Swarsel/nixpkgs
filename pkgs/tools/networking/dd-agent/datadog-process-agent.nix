{ lib, datadog-agent }:
datadog-agent.overrideAttrs (attrs: {
  pname = "datadog-process-agent";
  postInstall = null;
  subPackages = [ "cmd/process-agent" ];

  meta =

    attrs.meta // {
      description = "Live process collector for the DataDog Agent v7";
      maintainers = [ ];
      mainProgram = "process-agent";
    };
})
