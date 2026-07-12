import re

file_path = '/Users/piyush/Documents/perfectbandhan/shadi_frontend/lib/widgets/profile_details_sheet.dart'
with open(file_path, 'r') as f:
    content = f.read()

# Update standard share
old_share1 = """                    final shareUrl = 'https://app.perfectbandhan.in/profile/${widget.profile.id}';
                    Share.share('Check out ${widget.profile.name}\\\'s profile on Perfect Bandhan!\\n$shareUrl');"""

new_share1 = """                    final shareId = widget.profile.pbId.isNotEmpty ? widget.profile.pbId : widget.profile.id;
                    final shareUrl = 'https://humsafar.piyushassudani.in/p/$shareId';
                    Share.share('Check out ${widget.profile.name}\\\'s profile on Perfect Bandhan!\\n$shareUrl');"""

content = content.replace(old_share1, new_share1)

# Update whatsapp family share
old_share2 = """                  final shareUrl = 'https://play.google.com/store/apps/details?id=com.piyush.assudani';"""
new_share2 = """                  final shareId = widget.profile.pbId.isNotEmpty ? widget.profile.pbId : widget.profile.id;
                  final shareUrl = 'https://humsafar.piyushassudani.in/p/$shareId';"""
content = content.replace(old_share2, new_share2)

with open(file_path, 'w') as f:
    f.write(content)
print("profile_details_sheet.dart patched successfully for pbId sharing.")
