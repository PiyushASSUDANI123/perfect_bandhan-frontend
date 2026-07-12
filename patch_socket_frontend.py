import re

file_path = '/Users/piyush/Documents/perfectbandhan/shadi_frontend/lib/services/socket_service.dart'
with open(file_path, 'r') as f:
    content = f.read()

# Fix onMessageSent race condition
old_match = """      final pendingMessages = _messageQueue.values.where((msg) => msg['isSent'] == false).toList();
      for (var msg in pendingMessages) {
        if (msg['text'] == msgData['text']) {
          msg['isSent'] = true;
          _messageQueue.put(msg['id'], msg);
          break; // Found and updated
        }
      }"""

new_match = """      final pendingMessages = _messageQueue.values.where((msg) => msg['isSent'] == false).toList();
      for (var msg in pendingMessages) {
        // Match by localId to prevent duplicate message race conditions
        if (msg['id'] == msgData['localId']) {
          msg['isSent'] = true;
          _messageQueue.put(msg['id'], msg);
          break; // Found and updated
        }
      }"""

content = content.replace(old_match, new_match)

with open(file_path, 'w') as f:
    f.write(content)
print("socket_service.dart patched.")
