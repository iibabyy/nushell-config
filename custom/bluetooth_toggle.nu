export def --wrapped BluetoothConnector [
    --toggle
    ...rest: string       # Captures all other flags and paths
] {
	if not $toggle {
		return (^BluetoothConnector ...$rest)
	}

	if (^BluetoothConnector --status ...$rest) == "Connected" {
		^BluetoothConnector --disconnect ...$rest
	} else {
		^BluetoothConnector --connect ...$rest
	}
}

# toggle airpods between the current device and another one
# the other device need to connect automatically to airpods whenever they are not connected to the current device
#
# REQUIREMENTS:
# 	1. spotify_player: cargo install spotify_player --locked
# 	2. BluetoothConnector: brew install bluetoothconnector
export def toggle_airpods_and_spotify [
	airpod_mac_address: string,
	current_device_name: string # current device name on Spotify
	other_device_name: string # other device name on Spotify
]: nothing -> string {
	if (which spotify_player | is-empty) {
		return "spotify_player not found"
	}
	if (which BluetoothConnector | is-empty) {
		return "BluetoothConnector not found"
	}

	let device_to_connect_to = if (BluetoothConnector --status $airpod_mac_address | str trim) == "Connected" {
		$other_device_name
	} else {
		$current_device_name
	}

	BluetoothConnector --toggle $airpod_mac_address

	spotify_player connect --name $device_to_connect_to | complete
	if $device_to_connect_to == $current_device_name {
		mut timeout_counter = 0
		while (BluetoothConnector --status $airpod_mac_address | str trim) != "Connected" {
			print --stderr "Waiting for airpods to connect..."
			sleep 1sec
			$timeout_counter += 1
			if $timeout_counter > 10 {
				return "Airpods not connected"
			}
		}
		sleep 1sec
	} else {
		sleep 5sec
	}

	spotify_player playback play | complete
	return $"Airpods toggled to ($device_to_connect_to)"
}

# Toggle airpods between the current device and another one.
# For it to work, the other device need to automatically connect to the airpods whenever they are not connected to the current device
#
# Notes:
# 	- when connecting to the other device, we can't know exactly when the airpods are connected, so we wait for 5 seconds.
#	- connecting to the current device can feel more fluid, since we can know the exact time when airpods are connected
#
# Requirements:
# 	- `spotify_player`: https://github.com/aome510/spotify-player
# 	- `BluetoothConnector`: https://github.com/lapfelix/BluetoothConnector
export def toggle_airpods_and_spotify [
	airpod_mac_address: string@bluetooth_devices,
	current_device_name: string@spotify_devices # current device name on Spotify
	other_device_name: string@spotify_devices # other device name on Spotify
]: nothing -> string {
	if (which spotify_player | is-empty) {
		return "spotify_player not found"
	}
	if (which BluetoothConnector | is-empty) {
		return "BluetoothConnector not found"
	}

	let device_to_connect_to = if (BluetoothConnector --status $airpod_mac_address | str trim) == "Connected" {
		$other_device_name
	} else {
		$current_device_name
	}

	spotify_player connect --name $device_to_connect_to | complete
	BluetoothConnector --toggle $airpod_mac_address

	# let time for the airpods to connect
	if $device_to_connect_to == $current_device_name {
		# if the airpods needs to connect to the current device,
		# wait for the exact time where airpods are connected
		mut timeout_counter = 0
		while (BluetoothConnector --status $airpod_mac_address | str trim) != "Connected" {
			sleep 1sec
			$timeout_counter += 1
			if $timeout_counter > 10 {
				return "Timeout: Airpods not connected"
			}
		}

		sleep 1sec
	} else {
		sleep 5sec
	}

	return $"Airpods toggled to ($device_to_connect_to)"
}

export def bluetooth_devices []: nothing -> list {

	# get the known bluetooth devices
	let completions = if ($nu.os-info.name == "macos") {
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

	$completions | update value { str downcase | str replace --all ":" "-" }
}

export def spotify_devices []: nothing -> list {

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
