local modem = peripheral.wrap("top")
modem.open(4481)
print(os.pullEvent("modem_message"))
