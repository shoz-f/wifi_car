use Mix.Config

# Authorize the device to receive firmware using your public key.
# See https://hexdocs.pm/nerves_firmware_ssh/readme.html for more information
# on configuring nerves_firmware_ssh.

keys =
  [
    Path.join([System.user_home!(), ".ssh", "id_rsa.pub"]),
    Path.join([System.user_home!(), ".ssh", "id_ecdsa.pub"]),
    Path.join([System.user_home!(), ".ssh", "id_ed25519.pub"])
  ]
  |> Enum.filter(&File.exists?/1)

if keys == [],
  do:
    Mix.raise("""
    No SSH public keys found in ~/.ssh. An ssh authorized key is needed to
    log into the Nerves device and update firmware on it using ssh.
    See your project's config.exs for this error message.
    """)

config :nerves_firmware_ssh,
  authorized_keys: Enum.map(keys, &File.read!/1)

# Configure nerves_init_gadget.
# See https://hexdocs.pm/nerves_init_gadget/readme.html for more information.

# Setting the node_name will enable Erlang Distribution.
# Only enable this for prod if you understand the risks.
node_name = if Mix.env() != :prod, do: "rc_car"

target = System.get_env("MIX_TARGET")

#config :nerves_init_gadget,
#  ifname: "usb0",
#  address_method: :dhcpd,
#  mdns_domain: "nerves.local",
#  node_name: node_name,
#  node_host: :mdns_domain

if target == "rpi3" do
  config :nerves_init_gadget,
    ifname: "wlan0",
    address_method: :dhcp,
    mdns_domain: "nerves.local",
    node_name: node_name,
    node_host: :mdns_domain
else
  config :nerves_init_gadget,
    ifname: "eth0",
    address_method: :dhcpd,
    mdns_domain: "nerves.local",
    node_name: node_name,
    node_host: :mdns_domain
end

# Import target specific config. This must remain at the bottom
# of this file so it overrides the configuration defined above.
# Uncomment to use target specific configurations

# import_config "#{Mix.target()}.exs"

# Statically assign an address
# config :nerves_network, :default,
#   eth0: [
#   ipv4_address_method: :static,
#   ipv4_address: "192.168.0.2",
#   ipv4_subnet_mask: "255.255.255.0",
#   nameservers: ["8.8.8.8", "8.8.4.4"]
# ]

# Configure wireless settings
key_mgmt = System.get_env("NERVES_NETWORK_KEY_MGMT") || "WPA-PSK"

ssid = System.get_env("NERVES_NETWORK_SSID") || "Buffalo-G-706A"
psk  = System.get_env("NERVES_NETWORK_PSK")  || "s3xmvddv4buat"

config :nerves_network, :default,
  wlan0: [
    ssid: ssid,
    psk:  psk,
    key_mgmt: String.to_atom(key_mgmt)
  ]

config :nerves_leds, names: [green: "led0"]
