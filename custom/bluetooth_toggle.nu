# Toggle airpods and spotify connections between two devices.
#
# use `spotify_player` and `BluetoothConnector` to toggle the airpods connection
# as well as the device on which spotify is playing between the current device and another.
#
# --- Notes ---
#	use `--no-spotify` to only toggle the airpods connection.
#	use `--devices` to see available devices.
# 	use <tab> while typing the arguments for autocompletion.
#
# --- Requirements ---
# 	`spotify_player`: https://github.com/aome510/spotify-player
# 	`BluetoothConnector`: https://github.com/lapfelix/BluetoothConnector
@example "toggle between two devices" {toggle_airpods_and_spotify "Airpods Pro" "MacBook Pro" "iPhone"}
@example "list available devices" {toggle_airpods_and_spotify --devices}
@example "toggle airpods only" {toggle_airpods_and_spotify "Airpods Pro" "MacBook Pro" "iPhone" --no-spotify}
export def toggle_airpods_and_spotify [
	airpod_device?: string@bluetooth_devices # MAC address or bluetooth device name of the airpods
	current_device_name?: string@spotify_devices # current device name on Spotify
	other_device_name?: string@spotify_devices # device name to toggle with on Spotify
	--devices # list available devices
	--no-spotify # don't toggle spotify
]: nothing -> string {

	check_args_are_valid $airpod_device $current_device_name $other_device_name $devices $no_spotify
	check_dependencies $no_spotify

	if $devices {
		return (list_devices)
	}

	# parse $airpod_device into the arg needed by bluetooth manager
	let airpod_mac_address = parse_airpods_device $airpod_device

	let return_message = if not $no_spotify {
		let device_connected_to = toggle_spotify $airpod_mac_address $current_device_name $other_device_name
		$"Airpods and Spotify toggled to ($device_connected_to)"
	} else {
		"Airpods toggled"
	}

	# toggle the bluetooth connection to the airpods
	toggle_bluetooth_device $airpod_mac_address

	return $return_message
}

def is_bluetooth_connected [mac: string]: nothing -> bool {
	if ($nu.os-info.name == "macos") {
		(BluetoothConnector --status $mac | str trim) == "Connected"
	} else if ($nu.os-info.name == "linux") {
		let info = (do { bluetoothctl info $mac } | complete)
		if $info.exit_code == 0 {
			($info.stdout =~ "Connected: yes")
		} else {
			false
		}
	} else {
		false
	}
}

def toggle_bluetooth_device [mac: string] {
	if ($nu.os-info.name == "macos") {
		BluetoothConnector $mac
	} else if ($nu.os-info.name == "linux") {
		if (is_bluetooth_connected $mac) {
			bluetoothctl disconnect $mac
		} else {
			bluetoothctl connect $mac
		}
	}
}

def toggle_spotify [airpod_mac_address: string, current_device_name: string, other_device_name: string]: nothing -> string {
	let device_to_connect_to = do {
		let is_currently_connected = is_bluetooth_connected $airpod_mac_address
		if $is_currently_connected {
			$other_device_name
		} else {
			$current_device_name
		}
	}

	# toggle the device to which spotify is connected
	spotify_player connect --name $device_to_connect_to | complete

	$device_to_connect_to
}

def list_devices [] {
	let make_row = {|value: string, description: string| 
		"\t" + ($value | fill --alignment left --width 24) + "\t" + ($description | fill --alignment left --width 24)
	}

	let make_list = {|title: string, col_1: string, col_2: string, devices: list<record>|
		let col_1 = ((ansi default_bold) + $col_1 + (ansi reset))
		let col_2 = ((ansi default_bold) + $col_2 + (ansi reset))
		[
			((ansi green_bold) + $title + (ansi reset)),
			(do $make_row $col_1 $col_2),
			...($devices | each { do $make_row $in.value $in.description })
		]
		| str join "\n"
	}

	let spotify_devices = do $make_list "Spotify Devices" "Name" "Type" (spotify_devices)
	let bluetooth_devices = do $make_list "Bluetooth Devices" "MAC Address" "Name" (bluetooth_devices)

	[ $spotify_devices, $bluetooth_devices ] | flatten | str join "\n"
}

def check_args_are_valid [
	airpod_device?: string
	current_device_name?: string
	other_device_name?: string
	devices?: bool
	no_spotify?: bool
] {
	def raise_usage_error [] {
		const command = $"(ansi cyan_bold)toggle_airpods_and_spotify(ansi reset)"

		let usages = [
				$"(ansi green_bold)Usages:(ansi reset)"
				$"  ($command) <airpod_device> <current_device_name> <other_device_name>"
				$"  ($command) --no-spotify <airpod_device>"
				$"  ($command) --devices"
			]
			| str join "\n"

		error make --unspanned {
			code: "invalid arguments"
			msg: $usages,
			help: $"run `($command) --help` for more informations"
		}
	}

	if $devices {
		return true
	}

	if $airpod_device == null {
		raise_usage_error
	}

	if $no_spotify {
		return true
	} else if $current_device_name == null or $other_device_name == null {
		raise_usage_error
	}

	true
}

def check_dependencies [no_spotify?: bool] {
	if not $no_spotify and (which spotify_player | is-empty) {
		error make --unspanned {
			code: "missing dependency"
			msg: $"(ansi cyan_bold)spotify_player(ansi reset) not found"
			help: "see how to install it at https://github.com/aome510/spotify-player"
		}
	}

	if ($nu.os-info.name == "macos") and (which BluetoothConnector | is-empty) {
		error make --unspanned {
			code: "missing dependency"
			msg: $"(ansi cyan_bold)BluetoothConnector(ansi reset) not found"
			help: "see how to install it at https://github.com/lapfelix/BluetoothConnector"
		}
	} else if ($nu.os-info.name == "linux") and (which bluetoothctl | is-empty) {
		error make --unspanned {
			code: "missing dependency"
			msg: $"(ansi cyan_bold)bluetoothctl(ansi reset) not found"
			help: "install bluez package on your Linux distribution"
		}
	}
}	

# transform a MAC address or a device name
# into the format needed for bluetooth operations
def parse_airpods_device [value: string] {
	let is_mac_address = ($value =~ '^([0-9a-fA-F]{2}[:-]){5}([0-9a-fA-F]{2})$')
	let raw_mac = if $is_mac_address {
		$value
	} else {
		let bluetooth_device = bluetooth_devices | where { $in.description == $value }
		if ($bluetooth_device | is-empty) {
			const command = $"(ansi cyan_bold)toggle_airpods_and_spotify(ansi reset)"
			error make --unspanned {
				code: "invalid bluetooth device"
				msg: ("device '" + $value + "' not found")
				help: $"run `($command) --devices` to see available devices"
			}
		}
		$bluetooth_device.0.value
	}

	if ($nu.os-info.name == "macos") {
		$raw_mac | str replace ':' '-' --all
	} else {
		$raw_mac | str replace '-' ':' --all
	}
}

def bluetooth_devices []: nothing -> list {

	# get the known bluetooth devices
	if ($nu.os-info.name == "macos") {
		system_profiler SPBluetoothDataType | from yaml | get Bluetooth 
			| get Connected? "Not Connected"?
			| where { is-not-empty }
			| each { transpose name data }
			| flatten 
			| each {{ value: $in.data.Address, description: $in.name }}
	} else if ($nu.os-info.name == "linux") {
		let output = (do { bluetoothctl devices } | complete)
		if $output.exit_code == 0 {
			$output.stdout
				| lines
				| parse -r 'Device\s+(?<value>\S+)\s+(?<description>.+)'
		} else {
			[]
		}
	} else {
		[]
	}
}

def spotify_devices []: nothing -> list {

	# list<id, is_active, is_private_session, is_restricted, name, type, volume_percent>
	let devices = (spotify_player get key devices | from json)

	let get_name = {|device|
		let needs_quotes = ($device.name =~ '[\s()\[\]{}$|;<>\#*?]')

		if $needs_quotes {
			$"`($device.name)`"
		} else {
			$device.name
		}
	}

	let get_description = {|device|
		let active_msg = if $device.is_active { " (Active)" } else { "" }
		$device.type + $active_msg
	}

	$devices | each {{
		value: (do $get_name $in),
		description: (do $get_description $in)
	}}
}
