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
