local modem = peripheral.wrap("top")
modem.open(4481)
replyChannel, message, senderDistance = os.pullEvent("modem_message")
print(message)
