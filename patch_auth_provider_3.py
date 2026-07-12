import re

file_path = '/Users/piyush/Documents/perfectbandhan/shadi_frontend/lib/providers/auth_provider.dart'
with open(file_path, 'r') as f:
    content = f.read()

# Add strict loading guards to other endpoints
def patch_loading_guard(content, method_name, loading_var):
    pattern = f"  Future<void> {method_name}() async {{\n    if (_token == null) return;\n"
    if pattern in content:
        new_pattern = f"  Future<void> {method_name}() async {{\n    if (_token == null) return;\n    if ({loading_var}) return;\n"
        content = content.replace(pattern, new_pattern)
    return content

content = patch_loading_guard(content, "fetchIncomingInterests", "_isLoadingIncoming")
content = patch_loading_guard(content, "fetchConversations", "_isLoadingConversations")

with open(file_path, 'w') as f:
    f.write(content)
print("AuthProvider patched other endpoints with strict early returns.")
