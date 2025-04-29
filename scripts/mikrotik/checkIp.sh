system/script/add name=CheckIP source={
# variables
:local targetIP "10.0.0.7"
:local interfaceName "ether2"
:local disableTime 10s

# check ip
:if ([ping $targetIP count=1] = 0) do={
    # Disable interface PPP
    :log info "Disable proxmox3 interface $interfaceName"
    /interface ethernet disable $interfaceName

    :log info "Waiting $disableTime"
    :delay $disableTime

    :log info "Enabling interface $interfaceName"
    /interface ethernet enable $interfaceName
  } else {
    :log info "Proxmox node responded to ping at $targetIP. Exiting..."
    :log info "No action taken"
  }
}


