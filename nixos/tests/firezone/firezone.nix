{ pkgs, ... }:
let
  domain = "firezone.test";
  apiDomain = "api.firezone.test";

  # The portal dispatches requests to the web UI and the API based on the
  # hostname, so we need a certificate that is valid for both domains.
  certs =
    pkgs.runCommand "firezone-test-certs"
      {
        nativeBuildInputs = [
          (pkgs.minica.overrideAttrs (old: {
            # Make the generated certificates outlive cached derivations
            prePatch = ''
              sed -i 's_NotAfter: time.Now().AddDate(2, 0, 30),_NotAfter: time.Now().AddDate(20, 0, 0),_' main.go
            '';
          }))
        ];
      }
      ''
        minica --ca-key ca.key.pem --ca-cert ca.cert.pem --domains ${domain},${apiDomain}
        mkdir -p $out
        mv ca.*.pem ${domain}/*.pem $out/
      '';

  # Hash for "testpassword" - generated with argon2
  adminPasswordHash = "$argon2id$v=19$m=65536,t=3,p=4$ZnJvbW5peHBrZ3N0ZXN0$LZ3FT4vmNR2eH5dERJMgLo7HLQbZ3lbDcPvPjAK2W6U";

  # The base provisioning configuration which is modified by the specialisations
  provisionedAccount = {
    name = "My Account";
    gatewayGroups.site.name = "Site";
    actors = {
      admin = {
        type = "account_admin_user";
        name = "Admin";
        email = "admin@localhost.localdomain";
        passwordHash = adminPasswordHash;
      };
      client = {
        type = "service_account";
        name = "A client";
      };
    };
    # service accounts aren't members of 'Everyone' so we need to add a separate group
    groups.main = {
      name = "main";
      members = [
        "client"
        "admin"
      ];
    };
    resources.res1 = {
      type = "dns";
      name = "Dns Resource";
      address = "resource.example.com";
      gatewayGroups = [ "site" ];
      filters = [
        { protocol = "icmp"; }
        {
          protocol = "tcp";
          ports = [ 80 ];
        }
      ];
    };
    resources.res2 = {
      type = "ip";
      name = "Ip Resource";
      address = "172.20.2.1";
      gatewayGroups = [ "site" ];
    };
    resources.res3 = {
      type = "cidr";
      name = "Cidr Resource";
      address = "172.20.1.0/24";
      gatewayGroups = [ "site" ];
    };
    policies.pol1 = {
      description = "Allow anyone res1 access";
      group = "main";
      resource = "res1";
    };
    policies.pol2 = {
      description = "Allow anyone res2 access";
      group = "main";
      resource = "res2";
    };
    policies.pol3 = {
      description = "Allow anyone res3 access";
      group = "main";
      resource = "res3";
    };
  };

  changedAccount = pkgs.lib.recursiveUpdate provisionedAccount {
    name = "My Account (changed)";
    gatewayGroups.site.name = "Site (changed)";
    actors.admin.name = "Admin (changed)";
    actors.client.name = "A client (changed)";
    resources.res1 = {
      name = "Dns Resource (changed)";
      # Changed filters - only allow ICMP now
      filters = [ { protocol = "icmp"; } ];
    };
    resources.res2.name = "Ip Resource (changed)";
    resources.res3.name = "Cidr Resource (changed)";
    policies.pol1.description = "Allow anyone res1 access (changed)";
    policies.pol2.description = "Allow anyone res2 access (changed)";
    policies.pol3.description = "Allow anyone res3 access (changed)";
  };

  removedResourceAccount =
    builtins.removeAttrs changedAccount [
      "resources"
      "policies"
    ]
    // {
      # res1 and pol1 (which referenced res1) are removed
      resources = builtins.removeAttrs changedAccount.resources [ "res1" ];
      policies = builtins.removeAttrs changedAccount.policies [ "pol1" ];
    };

  commonNodeConfig =
    { nodes, ... }:
    {
      security.pki.certificateFiles = [ "${certs}/ca.cert.pem" ];
      networking.extraHosts = ''
        ${nodes.server.networking.primaryIPAddress} ${domain} ${apiDomain}
        ${nodes.server.networking.primaryIPv6Address} ${domain} ${apiDomain}
      '';
    };
in
{
  name = "firezone";
  meta.maintainers = with pkgs.lib.maintainers; [
    oddlama
    patrickdag
  ];

  nodes = {
    server =
      {
        config,
        lib,
        pkgs,
        ...
      }:
      {
        imports = [ commonNodeConfig ];

        # To debug problems:
        # 1. comment this in
        # 2. echo '127.0.0.1 firezone.test api.firezone.test' >> /etc/hosts
        # 3. socat TCP-LISTEN:443,fork TCP:127.0.0.1:12345
        # 4. Firezone has to succeed when sending mail
        #   - Get opensmtpd to work
        #   - add an actual mailaccount to the test
        # virtualisation.forwardPorts = [
        #   {
        #     from = "host";
        #     host.port = 12345;
        #     guest.port = 443;
        #   }
        # ];

        networking.firewall.allowedTCPPorts = [
          80
          443
        ];

        services.nginx.virtualHosts = lib.genAttrs [ domain apiDomain ] (_: {
          sslCertificate = "${certs}/cert.pem";
          sslCertificateKey = "${certs}/key.pem";
        });

        # This doesn't actually work firezone/Swoosh seems to send 2 `EHLO`
        # which opensmtpd does not allow
        # https://github.com/OpenSMTPD/OpenSMTPD/issues/1284
        # Would be nice for debbuging
        # services.opensmtpd = {
        #   enable = true;
        #   extraServerArgs = [ "-v" ];
        #   serverConfiguration = ''
        #     listen on 0.0.0.0
        #     action "local" maildir "/tmp/maildir"
        #     match for domain "localhost.localdomain" action "local"
        #   '';
        # };

        services.firezone.server = {
          enable = true;
          enableLocalDB = true;
          nginx.enable = true;

          # Doesn't need to work for this test, but needs to be configured
          # otherwise the server will not start.
          smtp = {
            from = "firezone@localhost.localdomain";
            host = "localhost";
            port = 25;
            implicitTls = false;
            username = "firezone@localhost.localdomain";
            passwordFile = pkgs.writeText "tmpmailpasswd" "verysecurepassword";
          };

          web.externalUrl = "https://${domain}/";
          api.externalUrl = "https://${apiDomain}/";

          provision = {
            enable = true;
            accounts.main = provisionedAccount;
          };
        };

        specialisation.changeAttributes.configuration = {
          services.firezone.server.provision.accounts.main = lib.mkForce changedAccount;
        };

        specialisation.removeResource.configuration = {
          services.firezone.server.provision.accounts.main = lib.mkForce removedResourceAccount;
        };

        systemd.services.firezone-server.postStart = lib.mkAfter ''
          ${lib.getExe config.services.firezone.server.package} rpc 'Code.eval_file("${./create-tokens.exs}")'
        '';
      };

    relay =
      { config, lib, ... }:
      {
        imports = [ commonNodeConfig ];

        services.firezone.relay = {
          enable = true;
          logLevel = "debug";
          name = "test-relay";
          apiUrl = "wss://${apiDomain}/";
          tokenFile = "/tmp/shared/relay_token.txt";
          publicIpv4 = config.networking.primaryIPAddress;
          publicIpv6 = config.networking.primaryIPv6Address;
          openFirewall = true;
        };

        # Don't auto-start so we can wait until the token was provisioned
        systemd.services.firezone-relay.wantedBy = lib.mkForce [ ];
      };

    # A resource that is only connected to the gateway,
    # allowing us to confirm the VPN works
    resource = {
      virtualisation.vlans = [
        1
        2
      ];

      networking.interfaces.eth1.ipv4.addresses = [
        {
          address = "172.20.1.1";
          prefixLength = 24;
        }
      ];

      networking.interfaces.eth2.ipv4.addresses = [
        {
          address = "172.20.2.1";
          prefixLength = 24;
        }
      ];

      networking.firewall.allowedTCPPorts = [
        80
      ];

      services.nginx = {
        enable = true;
        virtualHosts = {
          "localhost" = {
            default = true;
            locations."/".extraConfig = ''
              return 200 'greetings from the resource';
              add_header Content-Type text/plain;
            '';
          };
        };
      };
    };

    gateway =
      { lib, ... }:
      {
        imports = [ commonNodeConfig ];

        virtualisation.vlans = [
          1
          2
        ];

        networking = {
          interfaces.eth1.ipv4.addresses = [
            {
              address = "172.20.1.2";
              prefixLength = 24;
            }
          ];

          interfaces.eth2.ipv4.addresses = [
            {
              address = "172.20.2.2";
              prefixLength = 24;
            }
          ];

          firewall.enable = false;
          nftables.enable = true;
          nftables.tables."filter".family = "inet";
          nftables.tables."filter".content = ''
            chain incoming {
              type filter hook input priority 0; policy accept;
            }

            chain postrouting {
              type nat hook postrouting priority srcnat; policy accept;
              meta protocol ip iifname "tun-firezone" oifname { "eth1", "eth2" } masquerade random
            }

            chain forward {
              type filter hook forward priority 0; policy drop;
              iifname "tun-firezone" accept
              oifname "tun-firezone" accept
            }

            chain output {
              type filter hook output priority 0; policy accept;
            }
          '';

        };

        # The gateway resolves DNS resources via the system resolver, which in
        # the test VMs points to an unreachable upstream. Answer queries for the
        # resource locally instead (including an immediate NODATA for AAAA).
        services.dnsmasq = {
          enable = true;
          settings = {
            no-resolv = true;
            local = "/example.com/";
            address = "/resource.example.com/172.20.1.1";
          };
        };

        boot.kernel.sysctl."net.ipv4.ip_forward" = "1";
        boot.kernel.sysctl."net.ipv6.conf.default.forwarding" = "1";
        boot.kernel.sysctl."net.ipv6.conf.all.forwarding" = "1";

        services.firezone.gateway = {
          enable = true;
          logLevel = "debug";
          name = "test-gateway";
          apiUrl = "wss://${apiDomain}/";
          tokenFile = "/tmp/shared/gateway_token.txt";
        };

        # Don't auto-start so we can wait until the token was provisioned
        systemd.services.firezone-gateway.wantedBy = lib.mkForce [ ];
      };

    client =
      { lib, ... }:
      {
        imports = [ commonNodeConfig ];

        networking.useNetworkd = true;

        services.firezone.headless-client = {
          enable = true;
          logLevel = "debug";
          name = "test-client-somebody";
          apiUrl = "wss://${apiDomain}/";
          tokenFile = "/tmp/shared/client_token.txt";
        };

        # Don't auto-start so we can wait until the token was provisioned
        systemd.services.firezone-headless-client.wantedBy = lib.mkForce [ ];
      };
  };

  testScript =
    { nodes, ... }:
    let
      specialisations = "${nodes.server.system.build.toplevel}/specialisation";
    in
    ''
      from datetime import timedelta

      start_all()

      def connect_components():
          relay.succeed("systemctl start firezone-relay")
          relay.wait_for_unit("firezone-relay.service")
          relay.wait_until_succeeds("journalctl --since -2m --unit firezone-relay.service --grep 'Connected to portal.*${apiDomain}'", timeout=timedelta(seconds=30))

          gateway.succeed("systemctl start firezone-gateway")
          gateway.wait_for_unit("firezone-gateway.service")
          gateway.wait_until_succeeds("journalctl --since -2m --unit firezone-gateway.service --grep 'Connected to portal.*${apiDomain}'", timeout=timedelta(seconds=30))

          client.succeed("systemctl start firezone-headless-client")
          client.wait_for_unit("firezone-headless-client.service")
          client.wait_until_succeeds("journalctl --since -2m --unit firezone-headless-client.service --grep 'Connected to portal.*${apiDomain}'", timeout=timedelta(seconds=30))
          client.wait_until_succeeds("journalctl --since -2m --unit firezone-headless-client.service --grep 'Tunnel ready'", timeout=timedelta(seconds=30))

      def disconnect_components():
          client.succeed("systemctl stop firezone-headless-client")
          gateway.succeed("systemctl stop firezone-gateway")
          relay.succeed("systemctl stop firezone-relay")

      with subtest("Start server"):
          server.wait_for_unit("firezone-server.service")
          server.wait_until_succeeds("curl -Lsf https://${domain}/ | grep -i 'firezone'", timeout=timedelta(seconds=60))
          server.succeed("curl -sf https://${domain}/readyz | grep '\"status\":\"ready\"'")
          # The API only serves websockets and the REST API
          server.succeed("curl -s -o /dev/null -w '%{http_code}' https://${apiDomain}/ | grep -E '^40[0-9]$'")

          # Wait for tokens and copy them to shared folder
          server.wait_for_file("/var/lib/private/firezone/relay_token.txt")
          server.wait_for_file("/var/lib/private/firezone/gateway_token.txt")
          server.wait_for_file("/var/lib/private/firezone/client_token.txt")
          server.succeed("cp /var/lib/private/firezone/*_token.txt /tmp/shared")

      with subtest("Connect relay, gateway and client"):
          connect_components()
          relay.wait_until_succeeds("journalctl --since -2m --unit firezone-relay.service --grep 'Created allocation.*IPv4'", timeout=timedelta(seconds=30))
          relay.wait_until_succeeds("journalctl --since -2m --unit firezone-relay.service --grep 'Created allocation.*IPv6'", timeout=timedelta(seconds=30))
          # Assert both relay ips are known
          gateway.wait_until_succeeds("journalctl --since -2m --unit firezone-gateway.service --grep 'Updated allocation.*relay_ip4.*Some.*relay_ip6.*Some'", timeout=timedelta(seconds=30))

      with subtest("Check DNS based access"):
          # Check that we can access the resource through the VPN via DNS
          client.wait_until_succeeds("curl -4 -Lsf http://resource.example.com | grep 'greetings from the resource'", timeout=timedelta(seconds=30))

      with subtest("Check CIDR based access"):
          # Check that we can access the resource through the VPN via CIDR
          client.wait_until_succeeds("ping -4 -c1 -W1 172.20.1.1", timeout=timedelta(seconds=30))

      with subtest("Check IP based access"):
          # Check that we can access the resource through the VPN via IP
          client.wait_until_succeeds("ping -4 -c1 -W1 172.20.2.1", timeout=timedelta(seconds=30))

      with subtest("Test Provisioning - changeAttributes"):
          disconnect_components()

          server.succeed('${specialisations}/changeAttributes/bin/switch-to-configuration test')
          server.wait_for_unit("firezone-server.service")
          server.wait_until_succeeds("curl -Lsf https://${domain}/ | grep -i 'firezone'", timeout=timedelta(seconds=60))

          connect_components()

          # Wait for both client and gateway to set up the updated resource configuration
          client.wait_until_succeeds("journalctl --since -2m --unit firezone-headless-client.service --grep 'Activating resource.*Dns Resource .changed'", timeout=timedelta(seconds=30))

          # Test changed filters: res1 now only allows ICMP (no HTTP)
          client.wait_until_succeeds("ping -4 -c1 -W1 resource.example.com", timeout=timedelta(seconds=30))
          client.fail("curl -4 -Lsf --max-time 5 http://resource.example.com")

          # Other resources should still work
          client.wait_until_succeeds("ping -4 -c1 -W1 172.20.1.1", timeout=timedelta(seconds=30))
          client.wait_until_succeeds("ping -4 -c1 -W1 172.20.2.1", timeout=timedelta(seconds=30))

      with subtest("Test Provisioning - removeResource"):
          disconnect_components()

          server.succeed('${specialisations}/removeResource/bin/switch-to-configuration test')
          server.wait_for_unit("firezone-server.service")
          server.wait_until_succeeds("curl -Lsf https://${domain}/ | grep -i 'firezone'", timeout=timedelta(seconds=60))

          connect_components()

          # res1 (DNS resource) should no longer be accessible
          client.wait_until_fails("ping -4 -c3 -W1 resource.example.com", timeout=timedelta(seconds=30))

          # res2 and res3 should still work
          client.wait_until_succeeds("ping -4 -c1 -W1 172.20.1.1", timeout=timedelta(seconds=30))
          client.wait_until_succeeds("ping -4 -c1 -W1 172.20.2.1", timeout=timedelta(seconds=30))
    '';
}
