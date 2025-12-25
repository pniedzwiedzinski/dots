{ pkgs, lib, ... }:
let

chatScript = pkgs.writeText "gprs" ''
ABORT           BUSY
ABORT           VOICE
ABORT           "NO CARRIER"
ABORT           "NO DIALTONE"
ABORT           "NO DIAL TONE"
ABORT           "NO ANSWER"
ABORT           "DELAYED"
ABORT           "ERROR"

# cease if the modem is not attached to the network yet
ABORT           "+CGATT: 0"

""              AT
TIMEOUT         12
OK              ATH
OK              ATE1

# +CPIN provides the SIM card PIN
#OK              AT+CPIN="MY_4_DIGIT_PIN"

# +CFUN may allow to configure the handset to limit operations to
# GPRS/EDGE/UMTS/etc to save power, but the arguments are not standard
# except for 1 which means "full functionality".
#OK             AT+CFUN=1

OK              AT+CGDCONT=1,"IP","internet"
OK              ATD*99#
TIMEOUT         22
CONNECT         ""
'';

in
{
  services.pppd = {
    enable = true;
    peers.network4g = {
      enable = false;
      autostart = true;
      config = ''
        nocrtscts
        debug
        nodetach
        ipcp-accept-local
        ipcp-accept-remote
        # Assumes that your IP address is allocated dynamically by the ISP.
        noipdefault
        # Try to get the name server addresses from the ISP.
        usepeerdns
        # Use this connection as the default route.
        # defaultroute
        # Makes pppd "dial again" when the connection is lost.
        persist
        # Do not ask the remote to authenticate.
        noauth
        connect '${pkgs.ppp}/bin/chat -s -v -f ${chatScript} -T super'
        /dev/ttyAMA0
      '';
    };
  };

  # enable UART communication between RPi and SIM7600 board
  boot.kernelParams = lib.mkForce [
    #"console=ttyS0,115200n8"
    # https://forums.raspberrypi.com/viewtopic.php?t=246215
    #"8250.nr_uarts=1"
    "console=tty1"
    "nohibernate"
    "loglevel=7"
  ];

  hardware.deviceTree = {
    enable = true;
    overlays = [
      #{
      #  name = "disable-bt";
      #  dtboFile = "${pkgs.raspberrypifw}/share/raspberrypi/boot/overlays/disable-bt.dtbo";
      #}
      {
        name = "disable-bt";
        dtsText = ''
          /dts-v1/;
          /plugin/;
          / {
            compatible = "brcm,bcm2837";
            fragment@0 {
              target = <&uart1>;
              __overlay__ {
                status = "disabled";
              };
            };

            fragment@1 {
              target = <&uart0>;
              __overlay__ {
                pinctrl-names = "default";
                pinctrl-0 = <&uart0_pins>;
                status = "okay";
              };
            };

            fragment@2 {
              target = <&bt>;
              __overlay__ {
                status = "disabled";
              };
            };

            fragment@3 {
              target = <&uart0_pins>;
              __overlay__ {
                brcm,pins;
                brcm,function;
                brcm,pull;
              };
            };

            fragment@4 {
              target = <&bt_pins>;
              __overlay__ {
                brcm,pins;
                brcm,function;
                brcm,pull;
              };
            };

            fragment@5 {
              target-path = "/aliases";
              __overlay__ {
                serial0 = "/soc/serial@7e201000";
                serial1 = "/soc/serial@7e215040";
              };
            };

          };
        '';
      }
    ];
  };
  environment.systemPackages = [ pkgs.dtc ];


  services.vnstat.enable = true;

  systemd.services."network-failover-monitor" = {
  description = "Monitor network interface state changes and adjust routes";
  wantedBy = [ "multi-user.target" ];
  script = ''
    #!/bin/sh
    last_state=""
    PATH="$PATH:${pkgs.iproute2}/bin:${pkgs.systemd}/bin"
    
    # Monitor link state changes specifically for wlan0
    ip monitor dev wlan0 | while read -r line; do
      # Extract the interface state (UP or DOWN)
      state=$(echo "$line" | sed -n 's/.*state \(UP\|DOWN\).*/\1/p')
       
      # skip empty
      [ -z "$state" ] && continue

      # Only act on state changes (UP to DOWN or DOWN to UP)
      if [ "$state" != "$last_state" ]; then
        if [ "$state" = "UP" ]; then
          echo "Wi-Fi (wlan0) is UP"
          ip route del default
          ip route add default via 192.168.1.1 dev wlan0 metric 100
          systemctl restart cloudflared
        elif [ "$state" = "DOWN" ]; then
          echo "Wi-Fi (wlan0) is DOWN"
          echo "Switching to GSM (ppp0)"
          ip route del default
          ip route add default dev ppp0 metric 200
          systemctl restart cloudflared
        fi
        # Update the last state for future comparison
        last_state="$state"
      fi
    done 
  '';
};

}
