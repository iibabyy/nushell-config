# Toggle airpods and spotify connections between two devices.
#
# use `spotify_player` and `BluetoothConnector` to toggle the airpods connection
# as well as the device on which spotify is playing between the current device and another.
#
# --- Requirements ---
# 	`spotify_player`: https://github.com/aome510/spotify-player
# 	`BluetoothConnector`: https://github.com/lapfelix/BluetoothConnector
@example "toggle between two devices" {toggle_airpods_and_spotify "Airpods Pro" "MacBook Pro" "iPhone"}
@example "list available devices" {toggle_airpods_and_spotify --devices}
export def toggle_airpods_and_spotify [
	airpod_device?: string@bluetooth_devices # MAC address or bluetooth device name
	current_device_name?: string@spotify_devices # current device name on Spotify
	other_device_name?: string@spotify_devices # other device name on Spotify
	--devices # list available devices
]: nothing -> string {

	check_args_are_valid $airpod_device $current_device_name $other_device_name $devices
	check_dependencies

	if $devices {
		return (list_devices)
	}

	# parse $airpod_device into the arg needed by BluetoothConnector
	let airpod_mac_address = parse_airpods_device $airpod_device

	let device_to_connect_to = do {
		let is_currently_connected = (BluetoothConnector --status $airpod_mac_address | str trim) == "Connected"
		if $is_currently_connected {
			$other_device_name
		} else {
			$current_device_name
		}
	}

	# toggle the device to which spotify is connected
	spotify_player connect --name $device_to_connect_to | complete

	# toggle the bluetooth connection to the airpods
	BluetoothConnector $airpod_mac_address

	return $"Airpods toggled to ($device_to_connect_to)"
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
] {
	if $devices {
		return true
	}

	if $airpod_device == null or $current_device_name == null or $other_device_name == null {
		error make --unspanned {
			code: "invalid arguments"
			msg: "Usages:\n\ttoggle_airpods_and_spotify --devices\n\ttoggle_airpods_and_spotify <airpod_device> <current_device_name> <other_device_name>",
			help: "run `toggle_airpods_and_spotify --help` for more informations"
		}
	}

	true
}

def check_dependencies [] {
	if (which spotify_player | is-empty) {
		error make --unspanned {
			code: "missing dependency"
			msg: "`spotify_player` not found"
			help: "see how to install it at https://github.com/aome510/spotify-player"
		}
	}

	if (which BluetoothConnector | is-empty) {
		error make --unspanned {
			code: "missing dependency"
			msg: "`BluetoothConnector` not found"
			help: "see how to install it at https://github.com/lapfelix/BluetoothConnector"
		}
	}
}	

# transform a MAC address or a device name
# into the format needed for `BluetoothConnector` (xx-xx-xx-xx-xx-xx)
def parse_airpods_device [value: string] {
	let is_mac_address = ($value =~ '^([0-9a-fA-F]{2}[:-]){5}([0-9a-fA-F]{2})$')
	if $is_mac_address {
		return $value | str replace ':' '-'
	}

	let bluetooth_device = bluetooth_devices | where { $in.value == $value }
	if ($bluetooth_device | is-empty) {
		error make --unspanned {
			code: "invalid bluetooth device"
			msg: "Airpod device not found"
			help: "run `toggle_airpods_and_spotify --list` to see available devices"
		}
	}

	$bluetooth_device.value
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
		bluetoothctl devices Paired
			| lines
			| parse "Device {value} {description}"
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
