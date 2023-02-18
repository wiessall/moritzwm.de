{ config, pkgs, ... }:
{
  services.vaultwarden = {
    enable = true;
    dbBackend = "postgresql";
    config = {
      webVaultFolder = "${pkgs.vaultwarden-vault}/share/vaultwarden/vault";
      WEB_VAULT_ENABLED = true;
      WEBSOCKET_ENABLED = false;
      LOG_FILE = "/var/log/vaultwarden";
      LOG_LEVEL = "Info";
      SIGNUPS_ALLOWED = false;
      DISABLE_ADMIN_TOKEN = false;
      SHOW_PASSWORD_HINT = false;
      DOMAIN = "https://warden.moritzwm.de";
    };
    environmentFile = ./vaultwarden.secret;
  };

  security.acme.certs = {
    "warden.moritzwm.de" = {
      group = "nginx";
      keyType = "rsa2048";
    };
  };

  services.nginx = {
    recommendedGzipSettings = true;
    recommendedOptimisation = true;
    recommendedProxySettings = true;
    recommendedTlsSettings = true;
    virtualHosts = {
      "warden.moritzwm.de" = {
        forceSSL = true;
        enableACME = true;
        serverAliases = [ "warden.v2202205176338190863.megasrv.de" ];
        locations."/" = {
          proxyPass = "http://localhost:8000";
          proxyWebsockets = true;
        };
        locations."/notifications/hub" = {
          proxyPass = "http://localhost:3012";
          proxyWebsockets = true;
        };
        locations."/notifications/hub/negotiate" = {
          proxyPass = "http://localhost:8000";
          proxyWebsockets = true;
        };
      };
    };
  };
  services.postgresql = {
    ensureDatabases = [ "vaultwarden" ];
    ensureUsers = [
      { name = "vaultwarden";
        ensurePermissions."DATABASE vaultwarden" = "ALL PRIVILEGES";
      }
    ];
  };
}
